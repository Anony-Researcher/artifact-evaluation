// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract decimalsFacet is ERC20, Ownable {
    using Address for address;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    function decimals() public view virtual override returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
    function setBurnFee(uint256 burnFee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._burnFee = burnFee_;
    }
    function setMarketingFee(uint256 marketingFee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingFee = marketingFee_;
        ds._combinedLiquidityFee =
            marketingFee_ +
            ds._developerFee +
            ds._charityFee;
    }
    function setDeveloperFee(uint256 developerFee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._developerFee = developerFee_;
        ds._combinedLiquidityFee =
            ds._marketingFee +
            developerFee_ +
            ds._charityFee;
    }
    function setCharityFee(uint256 charityFee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._charityFee = charityFee_;
        ds._combinedLiquidityFee =
            ds._marketingFee +
            ds._developerFee +
            charityFee_;
    }
    function setNumTokensSellToAddToLiquidity(
        uint256 _minimumTokensBeforeSwap
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }
    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingAddress = payable(_marketingAddress);
    }
    function setDeveloperAddress(address _developerAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.developerAddress = payable(_developerAddress);
    }
    function setCharityAddress(address _charityAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.charityAddress = payable(_charityAddress);
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = maxTxAmount;
    }
    function excludeFromFee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = false;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 senderBalance = balanceOf(sender);
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        if (sender != owner() && recipient != owner()) {
            require(
                amount <= ds._maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            ds.minimumTokensBeforeSwap;

        if (
            !ds.inSwapAndLiquify &&
            ds.swapAndLiquifyEnabled &&
            recipient == ds.uniswapV2Pair
        ) {
            if (overMinimumTokenBalance) {
                contractTokenBalance = ds.minimumTokensBeforeSwap;
                swapTokens(contractTokenBalance);
            }
        }

        bool takeFee = true;

        if (ds._isExcludedFromFee[sender] || ds._isExcludedFromFee[recipient]) {
            takeFee = false;
        }

        _tokenTransfer(sender, recipient, amount, takeFee);
    }
    function presale(bool _presale) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_presale) {
            setSwapAndLiquifyEnabled(false);
            removeAllFee();
            ds._previousMaxTxAmount = ds._maxTxAmount;
            ds._maxTxAmount = totalSupply();
        } else {
            setSwapAndLiquifyEnabled(true);
            restoreAllFee();
            ds._maxTxAmount = ds._previousMaxTxAmount;
        }
    }
    function removeAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._burnFee == 0 && ds._combinedLiquidityFee == 0) return;

        ds._previousBurnFee = ds._burnFee;
        ds._previousCombinedLiquidityFee = ds._combinedLiquidityFee;
        ds._previousMarketingFee = ds._marketingFee;
        ds._previousDeveloperFee = ds._developerFee;
        ds._previousCharityFee = ds._charityFee;

        ds._burnFee = 0;
        ds._combinedLiquidityFee = 0;
        ds._marketingFee = 0;
        ds._developerFee = 0;
        ds._charityFee = 0;
    }
    function _tokenTransfer(
        address from,
        address to,
        uint256 value,
        bool takeFee
    ) private {
        if (!takeFee) {
            removeAllFee();
        }

        _transferStandard(from, to, value);

        if (!takeFee) {
            restoreAllFee();
        }
    }
    function _transferStandard(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 transferAmount = _getTransferValues(amount);

        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + transferAmount;

        _takeLiquidity(from, amount);
        burnFeeTransfer(from, amount);

        emit Transfer(from, to, transferAmount);
    }
    function _getTransferValues(uint256 amount) private view returns (uint256) {
        uint256 taxValue = _getCompleteTaxValue(amount);
        uint256 transferAmount = amount - taxValue;
        return transferAmount;
    }
    function _getCompleteTaxValue(
        uint256 amount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 allTaxes = ds._combinedLiquidityFee + ds._burnFee;
        uint256 taxValue = (amount * allTaxes) / 100;
        return taxValue;
    }
    function _takeLiquidity(address sender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 liquidity = (amount * ds._combinedLiquidityFee) / 100;
        _balances[address(this)] = _balances[address(this)] + liquidity;
        emit Transfer(sender, address(this), amount);
    }
    function burnFeeTransfer(address sender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 burnFee = (amount * ds._burnFee) / 100;
        if (burnFee > 0) {
            _totalSupply = _totalSupply - burnFee;
            emit Transfer(sender, address(0), burnFee);
        }
    }
    function restoreAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._burnFee = ds._previousBurnFee;
        ds._combinedLiquidityFee = ds._previousCombinedLiquidityFee;
        ds._marketingFee = ds._previousMarketingFee;
        ds._developerFee = ds._previousDeveloperFee;
        ds._charityFee = ds._previousCharityFee;
    }
    function swapTokens(uint256 contractTokenBalance) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractTokenBalance);
        uint256 transferredBalance = address(this).balance - initialBalance;

        transferToAddressETH(
            ds.marketingAddress,
            ((transferredBalance) * ds._marketingFee) / ds._combinedLiquidityFee
        );
        transferToAddressETH(
            ds.developerAddress,
            ((transferredBalance) * ds._developerFee) / ds._combinedLiquidityFee
        );
        transferToAddressETH(
            ds.charityAddress,
            ((transferredBalance) * ds._charityFee) / ds._combinedLiquidityFee
        );
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }
    function transferToAddressETH(
        address payable recipient,
        uint256 amount
    ) private {
        recipient.transfer(amount);
    }
}
