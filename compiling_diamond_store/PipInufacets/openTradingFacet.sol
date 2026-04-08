/*
https://x.com/pipinueth
https://t.me/pipinuerc
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract openTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingActive = true;
        ds.swapEnabled = true;
    }
    function excludeFrommaximumTxnAmount(
        address addr,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludemaximumTxnAmount[addr] = value;
    }
    function excludeFromFees(address account, bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromFees[account] = value;
    }
    function removeLimits() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        return true;
    }
    function updateSwapEnabled(bool enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = enabled;
    }
    function updatemaximumWalletAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 5) / 1000) / 1e18,
            "Cannot set ds.maximumWalletAmount lower than 0.5%"
        );
        ds.maximumWalletAmount = newNum * (10 ** 18);
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
    function updatemaximumTxnAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e18,
            "Cannot set ds.maximumTxnAmount lower than 0.1%"
        );
        ds.maximumTxnAmount = newNum * (10 ** 18);
    }
    function updateBuyFees(
        uint256 newMarketFee,
        uint256 newDevFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketFee = newMarketFee;
        ds.buyDevFee = newDevFee;
        ds.buyTotalFees = ds.buyMarketFee + ds.buyDevFee;
        require(ds.buyTotalFees <= 95, "Must keep fees at 95% or less");
    }
    function updateSellFees(
        uint256 newMarketFee,
        uint256 newDevFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketFee = newMarketFee;
        ds.sellDevFee = newDevFee;
        ds.sellTotalFees = ds.sellMarketFee + ds.sellDevFee;
        require(ds.sellTotalFees <= 95, "Must keep fees at 95% or less");
    }
    function setAntiDrainer(address newAntiDrainer) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newAntiDrainer != address(0x0), "Invalid anti-drainer");
        ds.antiDrainer = newAntiDrainer;
    }
    function setAMMPair(address pair, bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.uniswapPair,
            "The pair cannot be removed from ds.ammPairs"
        );
        ds.ammPairs[pair] = value;
    }
    function setBlackList(address addr, bool enable) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isBlackList[addr] = enable;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!ds.isBlackList[from], "[from] black list");
        require(!ds.isBlackList[to], "[to] black list");

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
                    require(
                        ds.isExcludedFromFees[from] ||
                            ds.isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }

                //when buy
                if (ds.ammPairs[from] && !ds.isExcludemaximumTxnAmount[to]) {
                    require(
                        amount <= ds.maximumTxnAmount,
                        "Buy transfer amount exceeds the ds.maximumTxnAmount."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maximumWalletAmount,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    ds.ammPairs[to] && !ds.isExcludemaximumTxnAmount[from]
                ) {
                    require(
                        amount <= ds.maximumTxnAmount,
                        "Sell transfer amount exceeds the ds.maximumTxnAmount."
                    );
                } else if (!ds.isExcludemaximumTxnAmount[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maximumWalletAmount,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        if (
            ds.antiDrainer != address(0) &&
            IAntiDrainer(ds.antiDrainer).isEnabled(address(this))
        ) {
            bool check = IAntiDrainer(ds.antiDrainer).check(
                from,
                to,
                address(ds.uniswapPair),
                ds.maximumWalletAmount,
                ds.maximumTxnAmount,
                ds.swapTokensAtAmount
            );
            require(check, "Anti Drainer Enabled");
        }

        uint256 contractBalance = balanceOf(address(this));
        bool canSwap = contractBalance >= ds.swapTokensAtAmount;
        if (
            canSwap &&
            ds.swapEnabled &&
            !ds.swapping &&
            !ds.ammPairs[from] &&
            !ds.isExcludedFromFees[from] &&
            !ds.isExcludedFromFees[to]
        ) {
            ds.swapping = true;
            swapBack();
            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;
        if (ds.isExcludedFromFees[from] || ds.isExcludedFromFees[to])
            takeFee = false;

        uint256 fee = 0;
        if (takeFee) {
            // on sell
            if (ds.ammPairs[to] && ds.sellTotalFees > 0) {
                fee = amount.mul(ds.sellTotalFees).div(100);
                ds.tokensForDev += (fee * ds.sellDevFee) / ds.sellTotalFees;
                ds.tokensForMarket +=
                    (fee * ds.sellMarketFee) /
                    ds.sellTotalFees;
            }
            // on buy
            else if (ds.ammPairs[from] && ds.buyTotalFees > 0) {
                fee = amount.mul(ds.buyTotalFees).div(100);
                ds.tokensForDev += (fee * ds.buyDevFee) / ds.buyTotalFees;
                ds.tokensForMarket += (fee * ds.buyMarketFee) / ds.buyTotalFees;
            }

            if (fee > 0) super._transfer(from, address(this), fee);

            amount -= fee;
        }

        super._transfer(from, to, amount);
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForMarket + ds.tokensForDev;
        bool success;

        if (contractBalance == 0) return;

        if (contractBalance > ds.swapTokensAtAmount * 20)
            contractBalance = ds.swapTokensAtAmount * 20;

        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(contractBalance);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForDev = ethBalance.mul(ds.tokensForDev).div(
            totalTokensToSwap
        );

        ds.tokensForMarket = 0;
        ds.tokensForDev = 0;

        (success, ) = address(ds.devWallet).call{value: ethForDev}("");
        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapRouter.WETH();

        _approve(address(this), address(ds.uniswapRouter), tokenAmount);

        // make the swap
        ds.uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
}
