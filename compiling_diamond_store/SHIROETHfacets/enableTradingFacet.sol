/*

    https://t.me/shiroeth

    https://shiro.bz

*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;
import "./TestLib.sol";
contract enableTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingActive = true;
        ds.swapEnabled = true;
    }
    function updateSwapTokensAtAmount(
        uint256 newAmount
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAmount >= (totalSupply() * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (totalSupply() * 5) / 1000,
            "Swap amount cannot be higher than 0.5% total supply."
        );
        ds.swapTokensAtAmount = newAmount;
        return true;
    }
    function updateMaxWalletAndTxnAmount(
        uint256 newTxnNum,
        uint256 newMaxWalletNum
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newTxnNum >= ((totalSupply() * 5) / 1000) / 1e18,
            "Cannot set maxTxn lower than 0.5%"
        );
        require(
            newMaxWalletNum >= ((totalSupply() * 5) / 1000) / 1e18,
            "Cannot set ds.maxWallet lower than 0.5%"
        );
        ds.maxWallet = newMaxWalletNum * (10 ** 18);
        ds.maxTransactionAmount = newTxnNum * (10 ** 18);
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function updateBuyFees(
        uint256 _marketingFee,
        uint256 _liquidityFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketingFee = _marketingFee;
        ds.buyLiquidityFee = _liquidityFee;
        ds.buyTotalFees = ds.buyMarketingFee + ds.buyLiquidityFee;
        require(ds.buyTotalFees <= 20, "Must keep fees at 20% or less");
    }
    function updateSellFees(
        uint256 _marketingFee,
        uint256 _liquidityFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketingFee = _marketingFee;
        ds.sellLiquidityFee = _liquidityFee;
        ds.sellTotalFees = ds.sellMarketingFee + ds.sellLiquidityFee;
        ds.previousFee = ds.sellTotalFees;
        require(ds.sellTotalFees <= 99, "Must keep fees at 99% or less");
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.uniswapV2Pair,
            "The pair cannot be removed from ds.automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
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
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead) &&
            !ds.swapping
        ) {
            if (!ds.tradingActive) {
                require(
                    ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to],
                    "Trading is not active."
                );
            }

            //when buy
            if (
                ds.automatedMarketMakerPairs[from] &&
                !ds._isExcludedMaxTransactionAmount[to]
            ) {
                require(
                    amount <= ds.maxTransactionAmount,
                    "Buy transfer amount exceeds the ds.maxTransactionAmount."
                );
                require(
                    amount + balanceOf(to) <= ds.maxWallet,
                    "Max wallet exceeded"
                );
            }
            //when sell
            else if (
                ds.automatedMarketMakerPairs[to] &&
                !ds._isExcludedMaxTransactionAmount[from]
            ) {
                require(
                    amount <= ds.maxTransactionAmount,
                    "Sell transfer amount exceeds the ds.maxTransactionAmount."
                );
            } else if (!ds._isExcludedMaxTransactionAmount[to]) {
                require(
                    amount + balanceOf(to) <= ds.maxWallet,
                    "Max wallet exceeded"
                );
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

        bool takeFee = !ds.swapping;

        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            // on sell
            if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                fees = amount.mul(ds.sellTotalFees).div(100);
                ds.tokensForLiquidity +=
                    (fees * ds.sellLiquidityFee) /
                    ds.sellTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.sellMarketingFee) /
                    ds.sellTotalFees;
            }
            // on buy
            else if (
                ds.automatedMarketMakerPairs[from] && ds.buyTotalFees > 0
            ) {
                fees = amount.mul(ds.buyTotalFees).div(100);
                ds.tokensForLiquidity +=
                    (fees * ds.buyLiquidityFee) /
                    ds.buyTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.buyMarketingFee) /
                    ds.buyTotalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
        ds.sellTotalFees = ds.previousFee;
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForLiquidity +
            ds.tokensForMarketing;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 20) {
            contractBalance = ds.swapTokensAtAmount * 20;
        }

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

        uint256 ethForLiquidity = ethBalance - ethForMarketing;

        ds.tokensForLiquidity = 0;
        ds.tokensForMarketing = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                ds.tokensForLiquidity
            );
        }

        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            deadAddress,
            block.timestamp
        );
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
