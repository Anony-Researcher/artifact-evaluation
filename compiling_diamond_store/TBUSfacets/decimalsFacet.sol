// Project Telegram: https://t.me/AllianceNetwork

// Contract has been created by <DEVAI> a Telegram AI bot. Visit https://t.me/ContractDevAI

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event TradingEnabled(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);
    event DisabledTransferDelay(uint256 indexed timestamp);
    event SwapbackSettingsUpdated(
        bool enabled,
        uint256 swapBackValueMin,
        uint256 swapBackValueMax
    );
    event MaxTxUpdated(uint256 maxTx);
    event MaxWalletUpdated(uint256 maxWallet);
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event BuyFeeUpdated(
        uint256 totalBuyFee,
        uint256 buyMktFee,
        uint256 buyLPFee,
        uint256 buyDevFee
    );
    event SellFeeUpdated(
        uint256 totalSellFee,
        uint256 sellMktFee,
        uint256 sellLpFee,
        uint256 sellDevFee
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event mktReceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event lpReceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event devReceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOn = true;

        ds.swapbackEnabled = true;

        emit TradingEnabled(block.timestamp);
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;

        emit LimitsRemoved(block.timestamp);
    }
    function disableTransferDelay() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.trasnferDelayEnabled = false;

        emit DisabledTransferDelay(block.timestamp);
    }
    function setSwapBackSettings(
        bool _enabled,
        uint256 _min,
        uint256 _max
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _min >= 1,
            "Swap amount cannot be lower than 0.01% total supply."
        );

        require(_max >= _min, "maximum amount cant be higher than minimum");

        ds.swapbackEnabled = _enabled;

        ds.swapBackValueMin = (totalSupply() * _min) / 10000;

        ds.swapBackValueMax = (totalSupply() * _max) / 10000;

        emit SwapbackSettingsUpdated(_enabled, _min, _max);
    }
    function setTxLimit(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newNum >= 1, "Cannot set ds.maxTx lower than 0.1%");

        ds.maxTx = (newNum * totalSupply()) / 1000;

        emit MaxTxUpdated(ds.maxTx);
    }
    function setWalletLimit(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newNum >= 5, "Cannot set ds.maxWallet lower than 0.5%");

        ds.maxWallet = (newNum * totalSupply()) / 1000;

        emit MaxWalletUpdated(ds.maxWallet);
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTxLimitExempt[updAds] = isEx;

        emit ExcludeFromLimits(updAds, isEx);
    }
    function setBuyFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMktFee = _marketingFee;

        ds.buyLPFee = _liquidityFee;

        ds.buyDevFee = _devFee;

        ds.totalBuyFee = ds.buyMktFee + ds.buyLPFee + ds.buyDevFee;

        require(
            ds.totalBuyFee <= 25,
            "Total buy fee cannot be higher than 25%"
        );

        emit BuyFeeUpdated(
            ds.totalBuyFee,
            ds.buyMktFee,
            ds.buyLPFee,
            ds.buyDevFee
        );
    }
    function setSellFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMktFee = _marketingFee;

        ds.sellLpFee = _liquidityFee;

        ds.sellDevFee = _devFee;

        ds.totalSellFee = ds.sellMktFee + ds.sellLpFee + ds.sellDevFee;

        require(
            ds.totalSellFee <= 25,
            "Total sell fee cannot be higher than 25%"
        );

        emit SellFeeUpdated(
            ds.totalSellFee,
            ds.sellMktFee,
            ds.sellLpFee,
            ds.sellDevFee
        );
    }
    function setTransferFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferMktFee = _marketingFee;

        ds.transferLpFee = _liquidityFee;

        ds.transferDevFee = _devFee;

        ds.totalTransferFee =
            ds.transferMktFee +
            ds.transferLpFee +
            ds.transferDevFee;

        require(
            ds.totalTransferFee <= 25,
            "Total transfer fee cannot be higher than 25%"
        );

        emit TransferFeeUpdated(
            ds.totalTransferFee,
            ds.transferMktFee,
            ds.transferLpFee,
            ds.transferDevFee
        );
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.dexPair,
            "The pair cannot be removed from ds.automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }
    function setMarketingWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit mktReceiverUpdated(newWallet, ds.mktReceiver);

        ds.mktReceiver = newWallet;
    }
    function setLPWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit lpReceiverUpdated(newWallet, ds.autoLPReceiver);

        ds.autoLPReceiver = newWallet;
    }
    function setDevWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit devReceiverUpdated(newWallet, ds.devReceiver);

        ds.devReceiver = newWallet;
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

        if (ds.limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !ds.swapping
            ) {
                if (!ds.tradingOn) {
                    require(
                        ds.isFeeExempt[from] || ds.isFeeExempt[to],
                        "Trading is not active."
                    );
                }

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.

                if (ds.trasnferDelayEnabled) {
                    if (
                        to != owner() &&
                        to != address(ds.dexRouter) &&
                        to != address(ds.dexPair)
                    ) {
                        require(
                            ds._holderLastTransferTimestamp[tx.origin] <
                                block.number,
                            "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                        );

                        ds._holderLastTransferTimestamp[tx.origin] = block
                            .number;
                    }
                }

                //when buy

                if (
                    ds.automatedMarketMakerPairs[from] &&
                    !ds.isTxLimitExempt[to]
                ) {
                    require(
                        amount <= ds.maxTx,
                        "Buy transfer amount exceeds the ds.maxTx."
                    );

                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    ds.automatedMarketMakerPairs[to] &&
                    !ds.isTxLimitExempt[from]
                ) {
                    require(
                        amount <= ds.maxTx,
                        "Sell transfer amount exceeds the ds.maxTx."
                    );
                } else if (!ds.isTxLimitExempt[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= ds.swapBackValueMin;

        if (
            canSwap &&
            ds.swapbackEnabled &&
            !ds.swapping &&
            !ds.automatedMarketMakerPairs[from] &&
            !ds.isFeeExempt[from] &&
            !ds.isFeeExempt[to]
        ) {
            ds.swapping = true;

            swapBack();

            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee

        if (ds.isFeeExempt[from] || ds.isFeeExempt[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        // only take fees on buys/sells, do not take on wallet transfers

        if (takeFee) {
            // on sell

            if (ds.automatedMarketMakerPairs[to] && ds.totalSellFee > 0) {
                fees = amount.mul(ds.totalSellFee).div(100);

                ds.tokensForLiquidity +=
                    (fees * ds.sellLpFee) /
                    ds.totalSellFee;

                ds.tokensForDev += (fees * ds.sellDevFee) / ds.totalSellFee;

                ds.tokensForMarketing +=
                    (fees * ds.sellMktFee) /
                    ds.totalSellFee;
            }
            // on buy
            else if (ds.automatedMarketMakerPairs[from] && ds.totalBuyFee > 0) {
                fees = amount.mul(ds.totalBuyFee).div(100);

                ds.tokensForLiquidity += (fees * ds.buyLPFee) / ds.totalBuyFee;

                ds.tokensForDev += (fees * ds.buyDevFee) / ds.totalBuyFee;

                ds.tokensForMarketing += (fees * ds.buyMktFee) / ds.totalBuyFee;
            }
            // on transfer
            else if (ds.totalTransferFee > 0) {
                fees = amount.mul(ds.totalTransferFee).div(100);

                ds.tokensForLiquidity +=
                    (fees * ds.transferLpFee) /
                    ds.totalTransferFee;

                ds.tokensForDev +=
                    (fees * ds.transferDevFee) /
                    ds.totalTransferFee;

                ds.tokensForMarketing +=
                    (fees * ds.transferMktFee) /
                    ds.totalTransferFee;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));

        uint256 totalTokensToSwap = ds.tokensForLiquidity +
            ds.tokensForMarketing +
            ds.tokensForDev;

        bool success;

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > ds.swapBackValueMax) {
            contractBalance = ds.swapBackValueMax;
        }

        // Halve the amount of liquidity tokens

        uint256 liquidityTokens = (contractBalance * ds.tokensForLiquidity) /
            totalTokensToSwap /
            2;

        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForMarketing = ethBalance.mul(ds.tokensForMarketing).div(
            totalTokensToSwap
        );

        uint256 ethForDev = ethBalance.mul(ds.tokensForDev).div(
            totalTokensToSwap
        );

        uint256 ethForLiquidity = ethBalance - ethForMarketing - ethForDev;

        ds.tokensForLiquidity = 0;

        ds.tokensForMarketing = 0;

        ds.tokensForDev = 0;

        (success, ) = address(ds.devReceiver).call{value: ethForDev}("");

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);

            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                ds.tokensForLiquidity
            );
        }

        (success, ) = address(ds.mktReceiver).call{
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
            ds.autoLPReceiver,
            block.timestamp
        );
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
