// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    event TradingEnabled(bool tradingEnabled);
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return tokenFromReflection(ds._rOwned[account]);
    }
    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds._isExcludedFromFee[accounts[i]] = excluded;
        }
    }
    function toggleautoSwapEnabled(bool _autoSwapEnabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.autoSwapEnabled = _autoSwapEnabled;
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
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "Trading already enabled.");
        ds.tradingEnabled = true;

        emit TradingEnabled(ds.tradingEnabled);
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
                "the transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function setMinSwapTokensThreshold(
        uint256 minSwappableAmount
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._minSwappableAmount = minSwappableAmount;
    }
    function updateFee(uint256 feeOnBuy, uint256 feeOnSell) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            feeOnBuy >= 0 && feeOnBuy <= 30,
            "Buy tax must be between 0% and 30%"
        );
        require(
            feeOnSell >= 0 && feeOnSell <= 30,
            "Sell tax must be between 0% and 30%"
        );

        ds._feeOnBuy = feeOnBuy;
        ds._feeOnSell = feeOnSell;
    }
    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            maxTxAmount >= (totalSupply() / (10 ** decimals())) / 100,
            "Max Transaction limit cannot be lower than 1% of total supply"
        );

        ds._maxTxnSize = maxTxAmount;
    }
    function setMaxHoldSize(uint256 maxHoldSize) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            maxHoldSize >= (totalSupply() / (10 ** decimals())) / 100,
            "Max wallet percentage cannot be lower than 1%"
        );

        ds._maxHoldSize = maxHoldSize;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "Cant transfer from address zero");
        require(to != address(0), "Cant transfer to address zero");
        require(amount > 0, "Amount should be above zero");

        if (from != owner() && to != owner()) {
            //Trade start check
            if (!ds.tradingEnabled) {
                require(
                    from == owner(),
                    "Only owner can trade before trading activation"
                );
            }

            require(amount <= ds._maxTxnSize, "Exceeded max transaction limit");

            if (to != ds.uniswapV2Pair) {
                require(
                    balanceOf(to) + amount < ds._maxHoldSize,
                    "Exceeds max hold balance"
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool swapAllowed = contractTokenBalance >= ds._minSwappableAmount;

            if (contractTokenBalance >= ds._maxTxnSize) {
                contractTokenBalance = ds._maxTxnSize;
            }

            if (
                swapAllowed &&
                !ds.swapping &&
                from != ds.uniswapV2Pair &&
                ds.autoSwapEnabled &&
                !ds._isExcludedFromFee[from] &&
                !ds._isExcludedFromFee[to]
            ) {
                covertToNative(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    transferEthToDev(address(this).balance);
                }
            }
        }

        bool takeFee = true;

        if (
            (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) ||
            (from != ds.uniswapV2Pair && to != ds.uniswapV2Pair)
        ) {
            takeFee = false;
        } else {
            if (from == ds.uniswapV2Pair && to != address(ds.uniswapV2Router)) {
                ds._fee = ds._feeOnBuy;
            }

            if (to == ds.uniswapV2Pair && from != address(ds.uniswapV2Router)) {
                ds._fee = ds._feeOnSell;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }
    function covertToNative(uint256 tokenAmount) private lockTheSwap {
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
        require(owner != address(0), "Can't approve from zero address");
        require(spender != address(0), "Can't approve to zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferEthToDev(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._treasuryAddress.transfer(amount);
    }
    function forceSwap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._treasuryAddress);
        uint256 contractETHBalance = address(this).balance;
        transferEthToDev(contractETHBalance);
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) dropFee();
        _transferApplyingFees(sender, recipient, amount);
        if (!takeFee) restoreFee();
    }
    function dropFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._fee == 0) return;

        ds._backedUpFee = ds._fee;

        ds._fee = 0;
    }
    function _transferApplyingFees(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 tTransferAmount,
            uint256 tTeam
        ) = _getFeeValues(tAmount);
        ds._rOwned[sender] = ds._rOwned[sender].sub(rAmount);
        ds._rOwned[recipient] = ds._rOwned[recipient].add(rTransferAmount);
        _transferFeeDev(tTeam);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _getFeeValues(
        uint256 tAmount
    ) private view returns (uint256, uint256, uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint256 tTransferAmount, uint256 tTeam) = _getTValues(
            tAmount,
            ds._fee
        );
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(
            tAmount,
            tTeam,
            currentRate
        );
        return (rAmount, rTransferAmount, tTransferAmount, tTeam);
    }
    function _getTValues(
        uint256 tAmount,
        uint256 fee
    ) private pure returns (uint256, uint256) {
        uint256 tTeam = tAmount.mul(fee).div(100);
        uint256 tTransferAmount = tAmount.sub(tTeam);
        return (tTransferAmount, tTeam);
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function tokenFromReflection(
        uint256 rAmount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            rAmount <= ds._rTotal,
            "Amount has to be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._rTotal, _totalSupply);
    }
    function _transferFeeDev(uint256 tTeam) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        ds._rOwned[address(this)] = ds._rOwned[address(this)].add(rTeam);
    }
    function _getRValues(
        uint256 tAmount,
        uint256 tTeam,
        uint256 currentRate
    ) private pure returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rTeam);
        return (rAmount, rTransferAmount);
    }
    function restoreFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._fee = ds._backedUpFee;
    }
    function recover(address token) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._treasuryAddress);
        require(token != address(this));
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }

        IERC20(token).transfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }
}
