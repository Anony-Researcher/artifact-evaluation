/**

Website : https://bonkybinkbink.com
Telegram : https://t.me/bonkyarmyyylfg
Twitter : https://twitter.com/Bonkytoken
                  
                BONKY BINK BINK LOVES YOU ❤️
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
import "./TestLib.sol";
contract enableTradingFacet is ERC20, Ownable {
    event EnabledTrading();
    event RemovedLimits();
    event UpdatedMaxBuyAmount(uint256 newAmount);
    event UpdatedMaxSellAmount(uint256 newAmount);
    event UpdatedMaxWalletAmount(uint256 newAmount);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event CaughtEarlyBuyer(address sniper);
    event TransferForeignToken(address token, uint256 amount);
    event OwnerForcedSwapBack(uint256 timestamp);
    event BuyBackTriggered(uint256 amount);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event MaxTransactionExclusion(address _address, bool excluded);
    function enableTrading(uint256 deadBlocks) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive, "Cannot reenable trading");
        ds.tradingActive = true;
        ds.swapEnabled = true;
        ds.tradingActiveBlock = block.number;
        ds.blockForPenaltyEnd = ds.tradingActiveBlock + deadBlocks;
        emit EnabledTrading();
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        ds.transferDelayEnabled = false;
        emit RemovedLimits();
    }
    function manageBoughtEarly(address wallet, bool flag) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.boughtEarly[wallet] = flag;
    }
    function massManageBoughtEarly(
        address[] calldata wallets,
        bool flag
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < wallets.length; i++) {
            ds.boughtEarly[wallets[i]] = flag;
        }
    }
    function disableTransferDelay() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelayEnabled = false;
    }
    function updateMaxBuyAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 2) / 1000) / 1e18,
            "Cannot set max buy amount lower than 0.2%"
        );
        ds.maxBuyAmount = newNum * (10 ** 18);
        emit UpdatedMaxBuyAmount(ds.maxBuyAmount);
    }
    function updateMaxSellAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 2) / 1000) / 1e18,
            "Cannot set max sell amount lower than 0.2%"
        );
        ds.maxSellAmount = newNum * (10 ** 18);
        emit UpdatedMaxSellAmount(ds.maxSellAmount);
    }
    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 3) / 1000) / 1e18,
            "Cannot set max wallet amount lower than 0.3%"
        );
        ds.maxWalletAmount = newNum * (10 ** 18);
        emit UpdatedMaxWalletAmount(ds.maxWalletAmount);
    }
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAmount >= (totalSupply() * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (totalSupply() * 1) / 1000,
            "Swap amount cannot be higher than 0.1% total supply."
        );
        ds.swapTokensAtAmount = newAmount;
    }
    function airdropToWallets(
        address[] memory wallets,
        uint256[] memory amountsInTokens
    ) external onlyOwner {
        require(
            wallets.length == amountsInTokens.length,
            "arrays must be the same length"
        );
        require(
            wallets.length < 600,
            "Can only airdrop 600 wallets per txn due to gas limits"
        ); // allows for airdrop + launch at the same exact time, reducing delays and reducing sniper input.
        for (uint256 i = 0; i < wallets.length; i++) {
            address wallet = wallets[i];
            uint256 amount = amountsInTokens[i];
            super._transfer(msg.sender, wallet, amount);
        }
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!isEx) {
            require(
                updAds != ds.lpPair,
                "Cannot remove uniswap pair from max txn"
            );
        }
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.lpPair,
            "The pair cannot be removed from ds.automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    function updateBuyFees(
        uint256 _operationsFee,
        uint256 _liquidityFee,
        uint256 _devFee,
        uint256 _burnFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyOperationsFee = _operationsFee;
        ds.buyLiquidityFee = _liquidityFee;
        ds.buyDevFee = _devFee;
        ds.buyBurnFee = _burnFee;
        ds.buyTotalFees =
            ds.buyOperationsFee +
            ds.buyLiquidityFee +
            ds.buyDevFee +
            ds.buyBurnFee;
        require(ds.buyTotalFees <= 30, "Must keep fees at 10% or less");
    }
    function updateSellFees(
        uint256 _operationsFee,
        uint256 _liquidityFee,
        uint256 _devFee,
        uint256 _burnFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellOperationsFee = _operationsFee;
        ds.sellLiquidityFee = _liquidityFee;
        ds.sellDevFee = _devFee;
        ds.sellBurnFee = _burnFee;
        ds.sellTotalFees =
            ds.sellOperationsFee +
            ds.sellLiquidityFee +
            ds.sellDevFee +
            ds.sellBurnFee;
        require(ds.sellTotalFees <= 30, "Must keep fees at 10% or less");
    }
    function returnToNormalTax() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellOperationsFee = 0;
        ds.sellLiquidityFee = 0;
        ds.sellDevFee = 0;
        ds.sellBurnFee = 0;
        ds.sellTotalFees =
            ds.sellOperationsFee +
            ds.sellLiquidityFee +
            ds.sellDevFee +
            ds.sellBurnFee;
        require(ds.sellTotalFees <= 30, "Must keep fees at 30% or less");

        ds.buyOperationsFee = 0;
        ds.buyLiquidityFee = 0;
        ds.buyDevFee = 0;
        ds.buyBurnFee = 0;
        ds.buyTotalFees =
            ds.buyOperationsFee +
            ds.buyLiquidityFee +
            ds.buyDevFee +
            ds.buyBurnFee;
        require(ds.buyTotalFees <= 30, "Must keep fees at 30% or less");
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount must be greater than 0");

        if (!ds.tradingActive) {
            require(
                ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to],
                "Trading is not active."
            );
        }

        if (ds.blockForPenaltyEnd > 0) {
            require(
                !ds.boughtEarly[from] || to == owner() || to == address(0xdead),
                "Bots cannot transfer tokens in or out except to owner or dead address."
            );
        }

        if (ds.limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !ds._isExcludedFromFees[from] &&
                !ds._isExcludedFromFees[to]
            ) {
                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (ds.transferDelayEnabled) {
                    if (
                        to != address(ds.dexRouter) && to != address(ds.lpPair)
                    ) {
                        require(
                            ds._holderLastTransferTimestamp[tx.origin] <
                                block.number - 2 &&
                                ds._holderLastTransferTimestamp[to] <
                                block.number - 2,
                            "_transfer:: Transfer Delay enabled.  Try again later."
                        );
                        ds._holderLastTransferTimestamp[tx.origin] = block
                            .number;
                        ds._holderLastTransferTimestamp[to] = block.number;
                    }
                }

                //when buy
                if (
                    ds.automatedMarketMakerPairs[from] &&
                    !ds._isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= ds.maxBuyAmount,
                        "Buy transfer amount exceeds the max buy."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maxWalletAmount,
                        "Cannot Exceed max wallet"
                    );
                }
                //when sell
                else if (
                    ds.automatedMarketMakerPairs[to] &&
                    !ds._isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= ds.maxSellAmount,
                        "Sell transfer amount exceeds the max sell."
                    );
                } else if (!ds._isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxWalletAmount,
                        "Cannot Exceed max wallet"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= ds.swapTokensAtAmount;

        if (
            canSwap &&
            ds.swapEnabled &&
            !ds.swapping &&
            !ds.automatedMarketMakerPairs[from] &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to]
        ) {
            ds.swapping = true;

            swapBack();

            ds.swapping = false;
        }

        bool takeFee = true;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // bot/sniper penalty.
            if (
                earlyBuyPenaltyInEffect() &&
                ds.automatedMarketMakerPairs[from] &&
                !ds.automatedMarketMakerPairs[to] &&
                ds.buyTotalFees > 0
            ) {
                if (!ds.boughtEarly[to]) {
                    ds.boughtEarly[to] = true;
                    ds.botsCaught += 1;
                    emit CaughtEarlyBuyer(to);
                }

                fees = (amount * 99) / 100;
                ds.tokensForLiquidity +=
                    (fees * ds.buyLiquidityFee) /
                    ds.buyTotalFees;
                ds.tokensForOperations +=
                    (fees * ds.buyOperationsFee) /
                    ds.buyTotalFees;
                ds.tokensForDev += (fees * ds.buyDevFee) / ds.buyTotalFees;
                ds.tokensForBurn += (fees * ds.buyBurnFee) / ds.buyTotalFees;
            }
            // on sell
            else if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                fees = (amount * ds.sellTotalFees) / 100;
                ds.tokensForLiquidity +=
                    (fees * ds.sellLiquidityFee) /
                    ds.sellTotalFees;
                ds.tokensForOperations +=
                    (fees * ds.sellOperationsFee) /
                    ds.sellTotalFees;
                ds.tokensForDev += (fees * ds.sellDevFee) / ds.sellTotalFees;
                ds.tokensForBurn += (fees * ds.sellBurnFee) / ds.sellTotalFees;
            }
            // on buy
            else if (
                ds.automatedMarketMakerPairs[from] && ds.buyTotalFees > 0
            ) {
                fees = (amount * ds.buyTotalFees) / 100;
                ds.tokensForLiquidity +=
                    (fees * ds.buyLiquidityFee) /
                    ds.buyTotalFees;
                ds.tokensForOperations +=
                    (fees * ds.buyOperationsFee) /
                    ds.buyTotalFees;
                ds.tokensForDev += (fees * ds.buyDevFee) / ds.buyTotalFees;
                ds.tokensForBurn += (fees * ds.buyBurnFee) / ds.buyTotalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function transferForeignToken(
        address _token,
        address _to
    ) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be 0");
        require(_token != address(this), "Can't withdraw native tokens");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
        emit TransferForeignToken(_token, _contractBalance);
    }
    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }
    function setOperationsAddress(
        address _operationsAddress
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _operationsAddress != address(0),
            "_operationsAddress address cannot be 0"
        );
        ds.operationsAddress = payable(_operationsAddress);
    }
    function setDevAddress(address _devAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_devAddress != address(0), "_devAddress address cannot be 0");
        ds.devAddress = payable(_devAddress);
    }
    function forceSwapBack() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            balanceOf(address(this)) >= ds.swapTokensAtAmount,
            "Can only swap when token amount is at or higher than restriction"
        );
        ds.swapping = true;
        swapBack();
        ds.swapping = false;
        emit OwnerForcedSwapBack(block.timestamp);
    }
    function buyBackTokens(uint256 amountInWei) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amountInWei <= 10 ether,
            "May not buy more than 10 ETH in a single buy to reduce sandwich attacks"
        );

        address[] memory path = new address[](2);
        path[0] = ds.dexRouter.WETH();
        path[1] = address(this);

        // make the swap
        ds.dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amountInWei
        }(
            0, // accept any amount of Ethereum
            path,
            address(0xdead),
            block.timestamp
        );
        emit BuyBackTriggered(amountInWei);
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds.tokensForBurn > 0 && balanceOf(address(this)) >= ds.tokensForBurn
        ) {
            _burn(address(this), ds.tokensForBurn);
        }
        ds.tokensForBurn = 0;

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForLiquidity +
            ds.tokensForOperations +
            ds.tokensForDev;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 60) {
            contractBalance = ds.swapTokensAtAmount * 60;
        }

        bool success;

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * ds.tokensForLiquidity) /
            totalTokensToSwap /
            2;

        swapTokensForEth(contractBalance - liquidityTokens);

        uint256 ethBalance = address(this).balance;
        uint256 ethForLiquidity = ethBalance;

        uint256 ethForOperations = (ethBalance * ds.tokensForOperations) /
            (totalTokensToSwap - (ds.tokensForLiquidity / 2));
        uint256 ethForDev = (ethBalance * ds.tokensForDev) /
            (totalTokensToSwap - (ds.tokensForLiquidity / 2));

        ethForLiquidity -= ethForOperations + ethForDev;

        ds.tokensForLiquidity = 0;
        ds.tokensForOperations = 0;
        ds.tokensForDev = 0;
        ds.tokensForBurn = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        (success, ) = address(ds.devAddress).call{value: ethForDev}("");

        (success, ) = address(ds.operationsAddress).call{
            value: address(this).balance
        }("");
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.dexRouter.WETH();

        _approve(address(this), address(ds.dexRouter), tokenAmount);

        // make the swap
        ds.dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.dexRouter), tokenAmount);

        // add the liquidity
        ds.dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0xdead),
            block.timestamp
        );
    }
    function earlyBuyPenaltyInEffect() public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return block.number < ds.blockForPenaltyEnd;
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        _excludeFromMaxTransaction(pair, value);

        emit SetAutomatedMarketMakerPair(pair, value);
    }
    function _excludeFromMaxTransaction(
        address updAds,
        bool isExcluded
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[updAds] = isExcluded;
        emit MaxTransactionExclusion(updAds, isExcluded);
    }
}
