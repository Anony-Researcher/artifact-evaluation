/** 
Twitter: https://twitter.com/FjordFoundry
Website: https://www.fjordfoundry.com/
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
import "./TestLib.sol";
contract launchFacet is ERC20, Ownable {
    event Launched();
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
    function launch(uint256 _deadblocks) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive, "Cannot reenable trading");
        ds.tradingActive = true;
        ds.swapEnabled = true;
        ds.tradingActiveBlock = block.number;
        ds.blockForPenaltyEnd = ds.tradingActiveBlock + _deadblocks;
        emit Launched();
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        ds.transferDelayEnabled = false;
        emit RemovedLimits();
    }
    function manageEarly(address wallet, bool flag) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.boughtEarly[wallet] = flag;
    }
    function disableTransferDelay() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelayEnabled = false;
    }
    function updateMaxBuy(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e18,
            "Cannot set max buy amount lower than 0.1%"
        );
        ds.maxBuy = newNum * (10 ** 18);
        emit UpdatedMaxBuyAmount(ds.maxBuy);
    }
    function updateMaxSell(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e18,
            "Cannot set max sell amount lower than 0.1%"
        );
        ds.maxSell = newNum * (10 ** 18);
        emit UpdatedMaxSellAmount(ds.maxSell);
    }
    function updateMaxWallet(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 3) / 1000) / 1e18,
            "Cannot set max wallet amount lower than 0.3%"
        );
        ds.maxWallet = newNum * (10 ** 18);
        emit UpdatedMaxWalletAmount(ds.maxWallet);
    }
    function updateSwapTokens(uint256 newAmount) external onlyOwner {
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
    function excludeFromMax(address updAds, bool isEx) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!isEx) {
            require(
                updAds != ds.lpPair,
                "Cannot remove uniswap pair from max txn"
            );
        }
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function setAMM(address pair, bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(pair != ds.lpPair, "The pair cannot be removed");

        _setAutomatedMarketMakerPair(pair, value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    function updateBuyFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _DevelopmentFee,
        uint256 _burnFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketingFee = _marketingFee;
        ds.buyLiquidityFee = _liquidityFee;
        ds.buyDevelopmentFee = _DevelopmentFee;
        ds.buyBurnFee = _burnFee;
        ds.buyTotalFees =
            ds.buyMarketingFee +
            ds.buyLiquidityFee +
            ds.buyDevelopmentFee +
            ds.buyBurnFee;
        require(ds.buyTotalFees <= 5, "Must keep fees at 5% or less");
    }
    function updateSellFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _DevelopmentFee,
        uint256 _burnFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketingFee = _marketingFee;
        ds.sellLiquidityFee = _liquidityFee;
        ds.sellDevelopmentFee = _DevelopmentFee;
        ds.sellBurnFee = _burnFee;
        ds.sellTotalFees =
            ds.sellMarketingFee +
            ds.sellLiquidityFee +
            ds.sellDevelopmentFee +
            ds.sellBurnFee;
        require(ds.sellTotalFees <= 5, "Must keep fees at 5% or less");
    }
    function returnToStandardTax() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketingFee = 5;
        ds.sellLiquidityFee = 0;
        ds.sellDevelopmentFee = 0;
        ds.sellBurnFee = 0;
        ds.sellTotalFees =
            ds.sellMarketingFee +
            ds.sellLiquidityFee +
            ds.sellDevelopmentFee +
            ds.sellBurnFee;
        require(ds.sellTotalFees <= 5, "Must keep fees at 5% or less");
        ds.buyMarketingFee = 5;
        ds.buyLiquidityFee = 0;
        ds.buyDevelopmentFee = 0;
        ds.buyBurnFee = 0;
        ds.buyTotalFees =
            ds.buyMarketingFee +
            ds.buyLiquidityFee +
            ds.buyDevelopmentFee +
            ds.buyBurnFee;
        require(ds.buyTotalFees <= 5, "Must keep fees at 5% or less");
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
                        amount <= ds.maxBuy,
                        "Buy transfer amount exceeds the max buy."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Cannot Exceed max wallet"
                    );
                }
                //when sell
                else if (
                    ds.automatedMarketMakerPairs[to] &&
                    !ds._isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= ds.maxSell,
                        "Sell transfer amount exceeds the max sell."
                    );
                } else if (!ds._isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
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
                ds.tokensForMarketing +=
                    (fees * ds.buyMarketingFee) /
                    ds.buyTotalFees;
                ds.tokensForDevelopment +=
                    (fees * ds.buyDevelopmentFee) /
                    ds.buyTotalFees;
                ds.tokensForBurn += (fees * ds.buyBurnFee) / ds.buyTotalFees;
            }
            // on sell
            else if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                fees = (amount * ds.sellTotalFees) / 100;
                ds.tokensForLiquidity +=
                    (fees * ds.sellLiquidityFee) /
                    ds.sellTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.sellMarketingFee) /
                    ds.sellTotalFees;
                ds.tokensForDevelopment +=
                    (fees * ds.sellDevelopmentFee) /
                    ds.sellTotalFees;
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
                ds.tokensForMarketing +=
                    (fees * ds.buyMarketingFee) /
                    ds.buyTotalFees;
                ds.tokensForDevelopment +=
                    (fees * ds.buyDevelopmentFee) /
                    ds.buyTotalFees;
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
    function setmarketingAddress(address _marketingAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _marketingAddress != address(0),
            "_marketingAddress address cannot be 0"
        );
        ds.marketingAddress = payable(_marketingAddress);
    }
    function setdevelopmentAddress(
        address _developmentAddress
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _developmentAddress != address(0),
            "_developmentAddress address cannot be 0"
        );
        ds.developmentAddress = payable(_developmentAddress);
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
    function buyBack(uint256 amountInWei) external onlyOwner {
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
            ds.tokensForMarketing +
            ds.tokensForDevelopment;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 20) {
            contractBalance = ds.swapTokensAtAmount * 20;
        }

        bool success;

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * ds.tokensForLiquidity) /
            totalTokensToSwap /
            2;

        swapTokensForEth(contractBalance - liquidityTokens);

        uint256 ethBalance = address(this).balance;
        uint256 ethForLiquidity = ethBalance;

        uint256 ethForMarketing = (ethBalance * ds.tokensForMarketing) /
            (totalTokensToSwap - (ds.tokensForLiquidity / 2));
        uint256 ethForDevelopment = (ethBalance * ds.tokensForDevelopment) /
            (totalTokensToSwap - (ds.tokensForLiquidity / 2));

        ethForLiquidity -= ethForMarketing + ethForDevelopment;

        ds.tokensForLiquidity = 0;
        ds.tokensForMarketing = 0;
        ds.tokensForDevelopment = 0;
        ds.tokensForBurn = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        (success, ) = address(ds.developmentAddress).call{
            value: ethForDevelopment
        }("");

        (success, ) = address(ds.marketingAddress).call{
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
