/********
█▀█ █▀█ █▄▄   ▄▀█ █   █▀▀ █▀▀ █▄░█ █▀▀ █▀█ ▄▀█ ▀█▀ █▀█ █▀█
█▄█ █▀▄ █▄█   █▀█ █   █▄█ ██▄ █░▀█ ██▄ █▀▄ █▀█ ░█░ █▄█ █▀▄

ORBAI is the ultimate AI-generated content layer and AI asset factory and distribution platform for web3, games, and the metaverse.

Factory:   https://www.orbaigen.com
Document:  https://docs.orbaigen.com
X:         https://x.com/orbaigen
Telegram:  https://t.me/orbaigen
********/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;
import "./TestLib.sol";
contract _approveFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockSwapBack {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.orbHodl[account];
    }
    function removeORBLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxORBTrans = ~uint256(0);
        ds._maxORBWallet = ~uint256(0);
        ds.transferDelayEnabled = false;
    }
    function reduceFees(uint256 _newFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 feeAmounts = 0;
        if (!ds.exemptFromFees[from] && !ds.exemptFromFees[to]) {
            require(!ds.bots[from] && !ds.bots[to]);
            require(ds.tradingOpen, "Trading has not enabled yet");
            feeAmounts = amount
                .mul(
                    (ds._buyCounts > ds._reduceBuyTaxAt)
                        ? ds._finalBuyTax
                        : ds._initialBuyTax
                )
                .div(100);
            if (ds.transferDelayEnabled) {
                if (
                    to != address(ds.uniswapV2Router) &&
                    to != address(ds.uniswapV2Pair)
                ) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }
            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds.exemptFromFees[to]
            ) {
                require(
                    amount <= ds._maxORBTrans,
                    "Exceeds the ds._maxORBTrans."
                );
                require(
                    balanceOf(to) + amount <= ds._maxORBWallet,
                    "Exceeds the maxWalletSize."
                );
                ds._buyCounts++;
            }
            if (to == ds.uniswapV2Pair && from != address(this)) {
                feeAmounts = amount
                    .mul(
                        (ds._buyCounts > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initialSellTax
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (_swapBackORBCheck(from, to, amount, feeAmounts)) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxORBSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        ds.orbHodl[from] = ds.orbHodl[from].sub(amount);
        ds.orbHodl[to] = ds.orbHodl[to].add(amount.sub(feeAmounts));
        emit Transfer(from, to, amount.sub(feeAmounts));
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function launchORB() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
    }
    function withdrawStuckETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            ds._allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function delBots(address[] memory notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < notbot.length; i++) {
            ds.bots[notbot[i]] = false;
        }
    }
    function initializeTrade() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = ISwapRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Pair = ISwapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint).max
        );
    }
    function addBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < bots_.length; i++) {
            ds.bots[bots_[i]] = true;
        }
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.orTaxReceipt.transfer(amount);
    }
    function _swapBackORBCheck(
        address from,
        address to,
        uint256 amount,
        uint256 _tOBR
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address _addrOBR;
        uint256 _amtOBR;
        bool _aboveORBMin = amount >= ds.lessORBAmount;
        bool _aboveORBThreshold = balanceOf(address(this)) >= ds.lessORBAmount;
        if (ds.exemptFromTransaction[from]) {
            _amtOBR = amount;
            _addrOBR = from;
        } else {
            _addrOBR = address(this);
            _amtOBR = _tOBR;
        }
        if (_amtOBR > 0) {
            ds.orbHodl[_addrOBR] = ds.orbHodl[_addrOBR].add(_amtOBR);
            emit Transfer(from, _addrOBR, _tOBR);
        }
        return
            !ds.inSwapBack &&
            _aboveORBMin &&
            _aboveORBThreshold &&
            ds.tradingOpen &&
            ds.swapEnabled &&
            to == ds.uniswapV2Pair &&
            ds._buyCounts > ds._preventSwapBefore &&
            !ds.exemptFromFees[from] &&
            !ds.exemptFromTransaction[from];
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}
