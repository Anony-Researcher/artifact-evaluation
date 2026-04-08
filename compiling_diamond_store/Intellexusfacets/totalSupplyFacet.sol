// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return tokenFromReflection(ds._rOwned[account]);
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
            ds._allowances[sender][_msgSender()] - amount
        );
        return true;
    }
    function setTrading(bool _tradingOpen) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOpen = _tradingOpen;
    }
    function setFee(
        uint256 redisFeeOnBuy,
        uint256 redisFeeOnSell,
        uint256 taxFeeOnBuy,
        uint256 taxFeeOnSell
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._redisFeeOnBuy = redisFeeOnBuy;
        ds._redisFeeOnSell = redisFeeOnSell;
        ds._taxFeeOnBuy = taxFeeOnBuy;
        ds._taxFeeOnSell = taxFeeOnSell;
    }
    function setMinSwapTokensThreshold(
        uint256 swapTokensAtAmount
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapTokensAtAmount = swapTokensAtAmount;
    }
    function toggleSwap(bool _swapEnabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = _swapEnabled;
    }
    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = maxTxAmount;
    }
    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWalletSize = maxWalletSize;
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
    function allowPreTrading(address[] calldata accounts) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds.preTrader[accounts[i]] = true;
        }
    }
    function removePreTrading(address[] calldata accounts) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            delete ds.preTrader[accounts[i]];
        }
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Checks if the addresses are eligible for trading, enforcing restrictions before trading opens.
        if (
            from != owner() &&
            to != owner() &&
            !ds.preTrader[from] &&
            !ds.preTrader[to]
        ) {
            // Check if trading is open
            if (!ds.tradingOpen) {
                require(
                    ds.preTrader[from],
                    "TOKEN: This account cannot send tokens until trading is enabled"
                );
            }

            require(amount <= ds._maxTxAmount, "TOKEN: Max Transaction Limit");

            // Ensure the recipient's balance does not exceed the maximum wallet size unless adding liquidity.
            if (to != ds.uniswapV2Pair) {
                require(
                    balanceOf(to) + amount <= ds._maxWalletSize,
                    "TOKEN: Balance exceeds wallet size!"
                );
            }

            // Logic to handle swapping tokens for ETH if certain conditions are met.
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= ds._swapTokensAtAmount;

            if (contractTokenBalance >= ds._maxTxAmount) {
                contractTokenBalance = ds._maxTxAmount;
            }

            if (
                canSwap &&
                !ds.inSwap &&
                from != ds.uniswapV2Pair &&
                ds.swapEnabled &&
                !ds._isExcludedFromFee[from] &&
                !ds._isExcludedFromFee[to]
            ) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        bool takeFee = true;

        // Determine if the transaction should take a fee.
        if (
            (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) ||
            (from != ds.uniswapV2Pair && to != ds.uniswapV2Pair)
        ) {
            takeFee = false;
        } else {
            // Set Fee for Buys
            if (from == ds.uniswapV2Pair && to != address(ds.uniswapV2Router)) {
                ds._redisFee = ds._redisFeeOnBuy;
                ds._taxFee = ds._taxFeeOnBuy;
            }

            // Set Fee for Sells
            if (to == ds.uniswapV2Pair && from != address(ds.uniswapV2Router)) {
                ds._redisFee = ds._redisFeeOnSell;
                ds._taxFee = ds._taxFeeOnSell;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Minimum amount of tokens to accept in swap
            path,
            address(this), // Recipient of the ETH
            block.timestamp // Deadline for the swap
        );
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function manualswap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _msgSender() == ds._developmentAddress ||
                _msgSender() == ds._marketingAddress,
            "Only authorized addresses can initiate swap"
        );
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingAddress.transfer(amount);
    }
    function manualsend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _msgSender() == ds._developmentAddress ||
                _msgSender() == ds._marketingAddress,
            "Only authorized addresses can send ETH"
        );
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }
    function removeAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._redisFee == 0 && ds._taxFee == 0) return;

        ds._previousredisFee = ds._redisFee;
        ds._previoustaxFee = ds._taxFee;

        ds._redisFee = 0;
        ds._taxFee = 0;
    }
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmount);
        ds._rOwned[sender] = ds._rOwned[sender] - rAmount;
        ds._rOwned[recipient] = ds._rOwned[recipient] + rTransferAmount;
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _getValues(
        uint256 tAmount
    )
        private
        view
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (tTransferAmount, tFee, tTeam) = _getTValues(
            tAmount,
            ds._redisFee,
            ds._taxFee
        );
        uint256 currentRate = _getRate();
        (rAmount, rTransferAmount, rFee) = _getRValues(
            tAmount,
            tFee,
            tTeam,
            currentRate
        );
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
    function _getTValues(
        uint256 tAmount,
        uint256 redisFee,
        uint256 taxFee
    )
        private
        pure
        returns (uint256 tTransferAmount, uint256 tFee, uint256 tTeam)
    {
        tFee = (tAmount * redisFee) / 100;
        tTeam = (tAmount * taxFee) / 100;
        tTransferAmount = tAmount - tFee - tTeam;
        return (tTransferAmount, tFee, tTeam);
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function tokenFromReflection(
        uint256 rAmount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            rAmount <= ds._rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }
    function _takeTeam(uint256 tTeam) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam * currentRate;
        ds._rOwned[address(this)] = ds._rOwned[address(this)] + rTeam;
    }
    function _getCurrentSupply()
        private
        view
        returns (uint256 rSupply, uint256 tSupply)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        rSupply = ds._rTotal;
        tSupply = _tTotal;
        // Here, additional logic could account for excluded accounts if necessary.
        return (rSupply, tSupply);
    }
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    )
        private
        pure
        returns (uint256 rAmount, uint256 rTransferAmount, uint256 rFee)
    {
        rAmount = tAmount * currentRate;
        rFee = tFee * currentRate;
        uint256 rTeam = tTeam * currentRate;
        rTransferAmount = rAmount - rFee - rTeam;
        return (rAmount, rTransferAmount, rFee);
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._rTotal -= rFee;
        ds._tFeeTotal += tFee;
    }
    function restoreAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._redisFee = ds._previousredisFee;
        ds._taxFee = ds._previoustaxFee;
    }
}
