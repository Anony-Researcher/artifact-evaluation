/**
 *Submitted for verification at Etherscan.io on 2022-12-19
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract activateTradingFacet is ERC20, Ownable {
    using Address for address;

    event TradingStatusChange(bool indexed newValue, bool indexed oldValue);
    event TradingStatusChange(bool indexed newValue, bool indexed oldValue);
    event AllowedWhenTradingDisabledChange(
        address indexed account,
        bool isExcluded
    );
    event BlockedAccountChange(address indexed holder, bool indexed status);
    event BlockedAccountChange(address indexed holder, bool indexed status);
    event FeeOnSelectedWalletTransfersChange(
        address indexed account,
        bool newValue
    );
    event ExcludeFromFeesChange(address indexed account, bool isExcluded);
    event ExcludeFromMaxTransferChange(
        address indexed account,
        bool isExcluded
    );
    event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);
    event UniswapV2RouterChange(
        address indexed newAddress,
        address indexed oldAddress
    );
    event MaxTransactionAmountChange(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );
    event MaxWalletAmountChange(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );
    event MinTokenAmountBeforeSwapChange(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );
    event ClaimOverflow(address token, uint256 amount);
    event ClaimOverflow(address token, uint256 amount);
    function activateTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTradingEnabled = true;
        if (ds._launchBlockNumber == 0) {
            ds._launchBlockNumber = block.number;
            ds._launchStartTimestamp = block.timestamp;
            ds._isLaunched = true;
        }
        emit TradingStatusChange(true, false);
    }
    function deactivateTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTradingEnabled = false;
        emit TradingStatusChange(false, true);
    }
    function allowTradingWhenDisabled(
        address account,
        bool allowed
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isAllowedToTradeWhenDisabled[account] = allowed;
        emit AllowedWhenTradingDisabledChange(account, allowed);
    }
    function blockAccount(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._isBlocked[account], "WWF: Account is already blocked");
        if (ds._isLaunched) {
            require(
                (block.timestamp - ds._launchStartTimestamp) < 172800,
                "WWF: Time to block accounts has expired"
            );
        }
        ds._isBlocked[account] = true;
        emit BlockedAccountChange(account, true);
    }
    function unblockAccount(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._isBlocked[account], "WWF: Account is not blcoked");
        ds._isBlocked[account] = false;
        emit BlockedAccountChange(account, false);
    }
    function setFeeOnSelectedWalletTransfers(
        address account,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._feeOnSelectedWalletTransfers[account] != value,
            "WWF: The selected wallet is already set to the value "
        );
        ds._feeOnSelectedWalletTransfers[account] = value;
        emit FeeOnSelectedWalletTransfersChange(account, value);
    }
    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFee[account] != excluded,
            "WWF: Account is already the value of 'excluded'"
        );
        ds._isExcludedFromFee[account] = excluded;
        emit ExcludeFromFeesChange(account, excluded);
    }
    function excludeFromMaxTransactionLimit(
        address account,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromMaxTransactionLimit[account] != excluded,
            "WWF: Account is already the value of 'excluded'"
        );
        ds._isExcludedFromMaxTransactionLimit[account] = excluded;
        emit ExcludeFromMaxTransferChange(account, excluded);
    }
    function excludeFromMaxWalletLimit(
        address account,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromMaxWalletLimit[account] != excluded,
            "WWF: Account is already the value of 'excluded'"
        );
        ds._isExcludedFromMaxWalletLimit[account] = excluded;
        emit ExcludeFromMaxWalletChange(account, excluded);
    }
    function setWallets(
        address newLiquidity1Wallet,
        address newLiquidity2Wallet,
        address newOperationsWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.liquidity1Wallet != newLiquidity1Wallet) {
            require(
                newLiquidity1Wallet != address(0),
                "WWF: The ds.liquidity1Wallet cannot be 0"
            );
            emit WalletChange(
                "ds.liquidity1Wallet",
                newLiquidity1Wallet,
                ds.liquidity1Wallet
            );
            ds.liquidity1Wallet = newLiquidity1Wallet;
        }
        if (ds.liquidity2Wallet != newLiquidity2Wallet) {
            require(
                newLiquidity2Wallet != address(0),
                "WWF: The ds.liquidity2Wallet cannot be 0"
            );
            emit WalletChange(
                "ds.liquidity2Wallet",
                newLiquidity2Wallet,
                ds.liquidity2Wallet
            );
            ds.liquidity2Wallet = newLiquidity2Wallet;
        }
        if (ds.operationsWallet != newOperationsWallet) {
            require(
                newOperationsWallet != address(0),
                "WWF: The ds.operationsWallet cannot be 0"
            );
            emit WalletChange(
                "ds.operationsWallet",
                newOperationsWallet,
                ds.operationsWallet
            );
            ds.operationsWallet = newOperationsWallet;
        }
    }
    function setBaseFeesOnBuy(
        uint8 _liquidity1FeeOnBuy,
        uint8 _liquidity2FeeOnBuy,
        uint8 _operationsFeeOnBuy
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _setCustomBuyTaxPeriod(
            ds._base,
            _liquidity1FeeOnBuy,
            _liquidity2FeeOnBuy,
            _operationsFeeOnBuy
        );
        emit FeeChange(
            "baseFees-Buy",
            _liquidity1FeeOnBuy,
            _liquidity2FeeOnBuy,
            _operationsFeeOnBuy
        );
    }
    function setBaseFeesOnSell(
        uint8 _liquidity1FeeOnSell,
        uint8 _liquidity2FeeOnSell,
        uint8 _operationsFeeOnSell
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _setCustomSellTaxPeriod(
            ds._base,
            _liquidity1FeeOnSell,
            _liquidity2FeeOnSell,
            _operationsFeeOnSell
        );
        emit FeeChange(
            "baseFees-Sell",
            _liquidity1FeeOnSell,
            _liquidity2FeeOnSell,
            _operationsFeeOnSell
        );
    }
    function setUniswapRouter(address newAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAddress != address(ds.uniswapV2Router),
            "WWF: The router already has that address"
        );
        emit UniswapV2RouterChange(newAddress, address(ds.uniswapV2Router));
        ds.uniswapV2Router = IRouter(newAddress);
    }
    function setMaxTransactionAmount(uint256 newValue) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newValue != ds.maxTxAmount,
            "WWF: Cannot update ds.maxTxAmount to same value"
        );
        emit MaxTransactionAmountChange(newValue, ds.maxTxAmount);
        ds.maxTxAmount = newValue;
    }
    function setMaxWalletAmount(uint256 newValue) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newValue != ds.maxWalletAmount,
            "WWF: Cannot update ds.maxWalletAmount to same value"
        );
        emit MaxWalletAmountChange(newValue, ds.maxWalletAmount);
        ds.maxWalletAmount = newValue;
    }
    function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newValue != ds.minimumTokensBeforeSwap,
            "WWF: Cannot update ds.minimumTokensBeforeSwap to same value"
        );
        emit MinTokenAmountBeforeSwapChange(
            newValue,
            ds.minimumTokensBeforeSwap
        );
        ds.minimumTokensBeforeSwap = newValue;
    }
    function claimLaunchTokens() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._launchStartTimestamp > 0, "WWF: Launch must have occurred");
        require(
            !ds._launchTokensClaimed,
            "WWF: Launch tokens have already been claimed"
        );
        require(
            block.number - ds._launchBlockNumber > 5,
            "WWF: Only claim launch tokens after launch"
        );
        uint256 tokenBalance = balanceOf(address(this));
        ds._launchTokensClaimed = true;
        require(
            ds.launchTokens <= tokenBalance,
            "WWF: A swap and liquify has already occurred"
        );
        uint256 amount = ds.launchTokens;
        ds.launchTokens = 0;
        bool success = IERC20(address(this)).transfer(owner(), amount);
        if (success) {
            emit ClaimOverflow(address(this), amount);
        }
    }
    function claimETHOverflow(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount <= address(this).balance,
            "WWF: Cannot send more than contract balance"
        );
        (bool success, ) = address(owner()).call{value: amount}("");
        if (success) {
            emit ClaimOverflow(ds.uniswapV2Router.WETH(), amount);
        }
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (
            !ds._isAllowedToTradeWhenDisabled[from] &&
            !ds._isAllowedToTradeWhenDisabled[to]
        ) {
            require(ds.isTradingEnabled, "WWF: Trading is currently disabled.");
            require(!ds._isBlocked[to], "WWF: Account is blocked");
            require(!ds._isBlocked[from], "WWF: Account is blocked");
            if (
                !ds._isExcludedFromMaxTransactionLimit[to] &&
                !ds._isExcludedFromMaxTransactionLimit[from]
            ) {
                require(
                    amount <= ds.maxTxAmount,
                    "WWF: Buy amount exceeds the maxTxBuyAmount."
                );
            }
            if (!ds._isExcludedFromMaxWalletLimit[to]) {
                require(
                    (balanceOf(to) + amount) <= ds.maxWalletAmount,
                    "WWF: Expected wallet amount exceeds the ds.maxWalletAmount."
                );
            }
        }

        _adjustTaxes(
            ds.automatedMarketMakerPairs[from],
            ds.automatedMarketMakerPairs[to],
            from,
            to
        );
        bool canSwap = balanceOf(address(this)) >= ds.minimumTokensBeforeSwap;

        if (
            ds.isTradingEnabled &&
            canSwap &&
            !ds._swapping &&
            ds._totalFee > 0 &&
            ds.automatedMarketMakerPairs[to]
        ) {
            ds._swapping = true;
            _swapAndLiquify();
            ds._swapping = false;
        }

        bool takeFee = !ds._swapping && ds.isTradingEnabled;

        if (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) {
            takeFee = false;
        }
        if (takeFee && ds._totalFee > 0) {
            uint256 fee = (amount * ds._totalFee) / 100;
            amount = amount - fee;
            if (
                ds._launchStartTimestamp > 0 &&
                (block.number - ds._launchBlockNumber <= 5)
            ) {
                ds.launchTokens += fee;
            }
            super._transfer(from, address(this), fee);
        }
        super._transfer(from, to, amount);
    }
    function _adjustTaxes(
        bool isBuyFromLp,
        bool isSelltoLp,
        address from,
        address to
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._liquidity1Fee = 0;
        ds._liquidity2Fee = 0;
        ds._operationsFee = 0;

        if (isBuyFromLp) {
            if (
                ds._isLaunched && block.timestamp - ds._launchBlockNumber <= 5
            ) {
                ds._liquidity1Fee = 100;
            } else {
                ds._liquidity1Fee = ds._base.liquidity1FeeOnBuy;
                ds._liquidity2Fee = ds._base.liquidity2FeeOnBuy;
                ds._operationsFee = ds._base.operationsFeeOnBuy;
            }
        }
        if (isSelltoLp) {
            ds._liquidity1Fee = ds._base.liquidity1FeeOnSell;
            ds._liquidity2Fee = ds._base.liquidity2FeeOnSell;
            ds._operationsFee = ds._base.operationsFeeOnSell;
        }
        if (
            !isSelltoLp &&
            !isBuyFromLp &&
            (ds._feeOnSelectedWalletTransfers[from] ||
                ds._feeOnSelectedWalletTransfers[to])
        ) {
            ds._liquidity1Fee = ds._base.liquidity1FeeOnBuy;
            ds._liquidity2Fee = ds._base.liquidity2FeeOnBuy;
            ds._operationsFee = ds._base.operationsFeeOnBuy;
        }
        ds._totalFee =
            ds._liquidity1Fee +
            ds._liquidity2Fee +
            ds._operationsFee;
        emit FeesApplied(
            ds._liquidity1Fee,
            ds._liquidity2Fee,
            ds._operationsFee,
            ds._totalFee
        );
    }
    function _swapAndLiquify() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 initialETHBalance = address(this).balance;

        uint256 amountToLiquify = (contractBalance * ds._liquidity1Fee) /
            ds._totalFee /
            2;
        uint256 amountToSwap = contractBalance - amountToLiquify;

        _swapTokensForETH(amountToSwap);

        uint256 ETHBalanceAfterSwap = address(this).balance - initialETHBalance;
        uint256 totalETHFee = ds._totalFee - (ds._liquidity1Fee / 2);
        uint256 amountETHLiquidity1 = (ETHBalanceAfterSwap *
            ds._liquidity1Fee) /
            totalETHFee /
            2;
        uint256 amountETHLiquidity2 = (ETHBalanceAfterSwap *
            ds._liquidity2Fee) / totalETHFee;
        uint256 amountETHOperations = ETHBalanceAfterSwap -
            (amountETHLiquidity1 + amountETHLiquidity2);

        Address.sendValue(payable(ds.operationsWallet), amountETHOperations);
        Address.sendValue(payable(ds.liquidity2Wallet), amountETHLiquidity2);

        if (amountToLiquify > 0) {
            _addLiquidity(amountToLiquify, amountETHLiquidity1);
            emit SwapAndLiquify(
                amountToSwap,
                amountETHLiquidity1,
                amountToLiquify
            );
        }
    }
    function _swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            1, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            1, // slippage is unavoidable
            1, // slippage is unavoidable
            ds.liquidity1Wallet,
            block.timestamp
        );
    }
    function _setCustomSellTaxPeriod(
        TestLib.CustomTaxPeriod storage map,
        uint8 _liquidity1FeeOnSell,
        uint8 _liquidity2FeeOnSell,
        uint8 _operationsFeeOnSell
    ) private {
        if (map.liquidity1FeeOnSell != _liquidity1FeeOnSell) {
            emit CustomTaxPeriodChange(
                _liquidity1FeeOnSell,
                map.liquidity1FeeOnSell,
                "liquidity1FeeOnSell",
                map.periodName
            );
            map.liquidity1FeeOnSell = _liquidity1FeeOnSell;
        }
        if (map.liquidity2FeeOnSell != _liquidity2FeeOnSell) {
            emit CustomTaxPeriodChange(
                _liquidity2FeeOnSell,
                map.liquidity2FeeOnSell,
                "liquidity2FeeOnSell",
                map.periodName
            );
            map.liquidity2FeeOnSell = _liquidity2FeeOnSell;
        }
        if (map.operationsFeeOnSell != _operationsFeeOnSell) {
            emit CustomTaxPeriodChange(
                _operationsFeeOnSell,
                map.operationsFeeOnSell,
                "operationsFeeOnSell",
                map.periodName
            );
            map.operationsFeeOnSell = _operationsFeeOnSell;
        }
    }
    function _setCustomBuyTaxPeriod(
        TestLib.CustomTaxPeriod storage map,
        uint8 _liquidity1FeeOnBuy,
        uint8 _liquidity2FeeOnBuy,
        uint8 _operationsFeeOnBuy
    ) private {
        if (map.liquidity1FeeOnBuy != _liquidity1FeeOnBuy) {
            emit CustomTaxPeriodChange(
                _liquidity1FeeOnBuy,
                map.liquidity1FeeOnBuy,
                "liquidity1FeeOnBuy",
                map.periodName
            );
            map.liquidity1FeeOnBuy = _liquidity1FeeOnBuy;
        }
        if (map.liquidity2FeeOnBuy != _liquidity2FeeOnBuy) {
            emit CustomTaxPeriodChange(
                _liquidity2FeeOnBuy,
                map.liquidity2FeeOnBuy,
                "liquidity2FeeOnBuy",
                map.periodName
            );
            map.liquidity2FeeOnBuy = _liquidity2FeeOnBuy;
        }
        if (map.operationsFeeOnBuy != _operationsFeeOnBuy) {
            emit CustomTaxPeriodChange(
                _operationsFeeOnBuy,
                map.operationsFeeOnBuy,
                "operationsFeeOnBuy",
                map.periodName
            );
            map.operationsFeeOnBuy = _operationsFeeOnBuy;
        }
    }
}
