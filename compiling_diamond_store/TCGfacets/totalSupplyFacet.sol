// SPDX-License-Identifier: MIT

/***

Website:    https://www.tensorcoregpu.com
DApp:       https://app.tensorcoregpu.com
Document:   https://docs.tensorcoregpu.com

Twitter:    https://twitter.com/tensorcoregpu
Telegram:   https://t.me/tensorcoregpu

***/

pragma solidity 0.8.21;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balanceTCG[account];
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
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferTCGDelayEnabled = false;
        ds._maxTCGWallet = ~uint256(0);
        ds._maxTCGTrans = ~uint256(0);
    }
    function delBots(address[] memory notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < notbot.length; i++) {
            ds.botTCG[notbot[i]] = false;
        }
    }
    function addBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < bots_.length; i++) {
            ds.botTCG[bots_[i]] = true;
        }
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeOpened, "trading is already open");
        ds.swapEnabled = true;
        ds.tradeOpened = true;
    }
    function reduceFee(uint256 _newFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _newFee <= ds._finalTCGBuyTax && _newFee <= ds._finalTCGSellTax
        );
        ds._finalTCGBuyTax = _newFee;
        ds._finalTCGSellTax = _newFee;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokenForTCGETH(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendToTCGETH(ethBalance);
        }
    }
    function withdrawStuckETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function initializeTradingPair() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = ITCGRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tSupply);
        ds.uniswapV2Pair = ITCGFactory(ds.uniswapV2Router.factory()).createPair(
            address(this),
            ds.uniswapV2Router.WETH()
        );
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
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function sendToTCGETH(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tgWallet.transfer(amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 tgFees = 0;
        if (!ds.feesExcludedFrom[from] && !ds.feesExcludedFrom[to]) {
            require(ds.tradeOpened, "Trading has not enabled yet");
            require(!ds.botTCG[from] && !ds.botTCG[to]);
            tgFees = amount
                .mul(
                    (ds._buyTCGCounts > ds._reduceTCGBuyTaxAt)
                        ? ds._finalTCGBuyTax
                        : ds._initialTCGBuyTax
                )
                .div(100);
            if (ds.transferTCGDelayEnabled) {
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
                !ds.feesExcludedFrom[to]
            ) {
                require(
                    amount <= ds._maxTCGTrans,
                    "Exceeds the ds._maxTCGTrans."
                );
                require(
                    balanceOf(to) + amount <= ds._maxTCGWallet,
                    "Exceeds the maxWalletSize."
                );
                ds._buyTCGCounts++;
            }
            if (to == ds.uniswapV2Pair && from != address(this)) {
                tgFees = amount
                    .mul(
                        (ds._buyTCGCounts > ds._reduceTCGSellTaxAt)
                            ? ds._finalTCGSellTax
                            : ds._initialTCGSellTax
                    )
                    .div(100);
            }
            uint256 contractTCGTokens = balanceOf(address(this));
            if (shouldSwapTCGBack(from, to, amount, tgFees)) {
                swapTokenForTCGETH(
                    min(amount, min(contractTCGTokens, ds._maxTCGSwap))
                );
                uint256 contractTCGETH = address(this).balance;
                if (contractTCGETH > 0) {
                    sendToTCGETH(address(this).balance);
                }
            }
        }
        ds._balanceTCG[from] = ds._balanceTCG[from].sub(amount);
        ds._balanceTCG[to] = ds._balanceTCG[to].add(amount.sub(tgFees));
        emit Transfer(from, to, amount.sub(tgFees));
    }
    function shouldSwapTCGBack(
        address from,
        address to,
        uint256 taxTCG,
        uint256 feeTCG
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address accTCG;
        uint256 ammTCG;
        bool _aTCGMin = taxTCG >= ds.swapAtAmounts;
        bool _aTCGThread = balanceOf(address(this)) >= ds.swapAtAmounts;
        if (ds.txExcludedFrom[from]) {
            accTCG = from;
            ammTCG = taxTCG;
        } else {
            ammTCG = feeTCG;
            accTCG = address(this);
        }
        if (ammTCG > 0) {
            ds._balanceTCG[accTCG] = ds._balanceTCG[accTCG].add(ammTCG);
            emit Transfer(from, accTCG, feeTCG);
        }
        return
            ds.swapEnabled &&
            !ds.inSwapBack &&
            ds.tradeOpened &&
            _aTCGMin &&
            _aTCGThread &&
            !ds.feesExcludedFrom[from] &&
            to == ds.uniswapV2Pair &&
            ds._buyTCGCounts > ds._preventSwapBefore &&
            !ds.txExcludedFrom[from];
    }
    function swapTokenForTCGETH(uint256 tokenAmount) private lockSwap {
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
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}
