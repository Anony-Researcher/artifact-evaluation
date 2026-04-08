// SPDX-License-Identifier: MIT
/*

VoidZ - Tokenization of Gaming Assets for Players and GPU Rental for Gaming Studios

Website: https://voidz.app/
Twitter/X: https://twitter.com/VoidZToken
Whitepaper: https://voidz.gitbook.io/voidz
TG: https://t.me/VoidZtoken

*/
pragma solidity 0.8.12;
import "./TestLib.sol";
contract updateMaxBuyAmountFacet is ERC20, Ownable {
    event UpdatedMaxBuyAmount(uint256 newAmount);
    event UpdatedMaxSellAmount(uint256 newAmount);
    event RemovedLimits();
    event UpdatedMaxWalletAmount(uint256 newAmount);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event EnabledTrading(bool tradingActive);
    event UpdatedTreasuryAddress(address indexed newWallet);
    event UpdatedEcosystemAddress(address indexed newWallet);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event MaxTransactionExclusion(address _address, bool excluded);
    function updateMaxBuyAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e18,
            "Cannot set max buy amount lower than 0.1%"
        );
        ds.maxBuyAmount = newNum * (10 ** 18);
        emit UpdatedMaxBuyAmount(ds.maxBuyAmount);
    }
    function updateMaxSellAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e18,
            "Cannot set max sell amount lower than 0.1%"
        );
        ds.maxSellAmount = newNum * (10 ** 18);
        emit UpdatedMaxSellAmount(ds.maxSellAmount);
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        emit RemovedLimits();
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!isEx) {
            require(
                updAds != ds.uniswapV2Pair,
                "Cannot remove uniswap pair from max txn"
            );
        }
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
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
    function updateBuyFees(
        uint256 _treasuryFee,
        uint256 _liquidityFee,
        uint256 _rewardsFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTreasuryFee = _treasuryFee;
        ds.buyLiquidityFee = _liquidityFee;
        ds.buyRewardsFee = _rewardsFee;
        ds.buyTotalFees =
            ds.buyTreasuryFee +
            ds.buyLiquidityFee +
            ds.buyRewardsFee;
        require(ds.buyTotalFees <= 30, "Fees must be 30%  or less");
    }
    function updateSellFees(
        uint256 _treasuryFee,
        uint256 _liquidityFee,
        uint256 _rewardsFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellTreasuryFee = _treasuryFee;
        ds.sellLiquidityFee = _liquidityFee;
        ds.sellRewardsFee = _rewardsFee;
        ds.sellTotalFees =
            ds.sellTreasuryFee +
            ds.sellLiquidityFee +
            ds.sellRewardsFee;
        require(ds.sellTotalFees <= 30, "Fees must be 30%  or less");
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

        if (ds.limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead)
            ) {
                if (!ds.tradingActive) {
                    require(
                        ds._isExcludedMaxTransactionAmount[from] ||
                            ds._isExcludedMaxTransactionAmount[to],
                        "Trading is not active."
                    );
                    require(from == owner(), "Trading is not enabled");
                }
                //when buy
                if (
                    ds.automatedMarketMakerPairs[from] &&
                    !ds._isExcludedMaxTransactionAmount[to] &&
                    block.number > ds.tradingActiveBlock
                ) {
                    require(
                        amount <= ds.maxBuyAmount,
                        "Buy transfer amount exceeds the max buy."
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
                }
                if (
                    !ds._isExcludedMaxTransactionAmount[to] &&
                    !ds._isExcludedMaxTransactionAmount[from]
                ) {
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
        uint256 penaltyAmount = 0;

        // only take fees on Trades, not on wallet transfers
        if (takeFee) {
            if (
                ds.tradingActiveBlock > 0 &&
                (ds.tradingActiveBlock + 1) > block.number
            ) {
                penaltyAmount = (amount * 10) / 100;
                super._transfer(from, ds.EcosystemAddress, penaltyAmount);
            }
            // on sell
            else if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                fees = (amount * ds.sellTotalFees) / 100;
                ds.tokensForLiquidity +=
                    (fees * ds.sellLiquidityFee) /
                    ds.sellTotalFees;
                ds.tokensForTreasury +=
                    (fees * ds.sellTreasuryFee) /
                    ds.sellTotalFees;
                ds.tokensForRewards +=
                    (fees * ds.sellRewardsFee) /
                    ds.sellTotalFees;
            }
            // on buy
            else if (
                ds.automatedMarketMakerPairs[from] && ds.buyTotalFees > 0
            ) {
                fees = (amount * ds.buyTotalFees) / 100;
                ds.tokensForLiquidity +=
                    (fees * ds.buyLiquidityFee) /
                    ds.buyTotalFees;
                ds.tokensForTreasury +=
                    (fees * ds.buyTreasuryFee) /
                    ds.buyTotalFees;
                ds.tokensForRewards +=
                    (fees * ds.buyRewardsFee) /
                    ds.buyTotalFees;
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees + penaltyAmount;
        }

        super._transfer(from, to, amount);
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.uniswapV2Pair,
            "The pair cannot be removed from ds.automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive, "Cannot re enable trading");
        ds.tradingActive = true;
        ds.swapEnabled = true;
        emit EnabledTrading(ds.tradingActive);

        if (ds.tradingActive && ds.tradingActiveBlock == 0) {
            ds.tradingActiveBlock = block.number;
        }
    }
    function setTreasuryAddress(address _TreasuryAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _TreasuryAddress != address(0),
            "_TreasuryAddress address cannot be 0"
        );
        ds.TreasuryAddress = payable(_TreasuryAddress);
        emit UpdatedTreasuryAddress(_TreasuryAddress);
    }
    function setEcosystemAddress(address _EcosystemAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _EcosystemAddress != address(0),
            "_EcosystemAddress address cannot be 0"
        );
        ds.EcosystemAddress = payable(_EcosystemAddress);
        emit UpdatedEcosystemAddress(_EcosystemAddress);
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
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForLiquidity +
            ds.tokensForTreasury +
            ds.tokensForRewards;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 5) {
            contractBalance = ds.swapTokensAtAmount * 5;
        }

        bool success;

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * ds.tokensForLiquidity) /
            totalTokensToSwap /
            2;

        swapTokensForEth(contractBalance - liquidityTokens);

        uint256 ethBalance = address(this).balance;
        uint256 ethForLiquidity = ethBalance;

        uint256 ethForTreasury = (ethBalance * ds.tokensForTreasury) /
            (totalTokensToSwap - (ds.tokensForLiquidity / 2));
        uint256 ethForRewards = (ethBalance * ds.tokensForRewards) /
            (totalTokensToSwap - (ds.tokensForLiquidity / 2));

        ethForLiquidity -= ethForTreasury + ethForRewards;

        ds.tokensForLiquidity = 0;
        ds.tokensForTreasury = 0;
        ds.tokensForRewards = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        (success, ) = address(ds.EcosystemAddress).call{value: ethForRewards}(
            ""
        );

        (success, ) = address(ds.TreasuryAddress).call{
            value: address(this).balance
        }("");
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
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // add the liquidity
        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(owner()),
            block.timestamp
        );
    }
}
