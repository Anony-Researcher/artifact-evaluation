// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract activateTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function activateTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bTradingActive = true;
        ds.bSwapEnabled = true;
    }
    function excludeFromMaxTokenAmountPerTxn(
        address addr,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bExcludedMaxTokenAmountPerTxn[addr] = value;
    }
    function excludeFromTax(address account, bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bExcludedFromTax[account] = value;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
    }
    function updateSwapEnabled(bool enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bSwapEnabled = enabled;
    }
    function updateMinimumSwapTokenAmount(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount >= (totalSupply() * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            amount <= (totalSupply() * 5) / 1000,
            "Swap amount cannot be higher than 0.5% total supply."
        );
        ds.taxSwapMin = amount;
    }
    function updateMaxTokensPerWallet(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 5) / 1000) / (10 ** decimals()),
            "Cannot set ds.maxTksAmtPerWallet lower than 0.5%"
        );
        ds.maxTksAmtPerWallet = newNum * (10 ** decimals());
    }
    function updateMaxTokenAmountPerTxn(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / (10 ** decimals()),
            "Cannot set ds.maxTokenAmountPerTxn lower than 0.1%"
        );
        ds.maxTokenAmountPerTxn = newNum * (10 ** decimals());
    }
    function setBlackList(
        address[] calldata wallets,
        bool blocked
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < wallets.length; i++) {
            ds.blackList[wallets[i]] = blocked;
        }
    }
    function updateBuyTax(
        uint256 newMarketFee,
        uint256 newDevFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketingTax = newMarketFee;
        ds.buyDevTax = newDevFee;
        ds.buyTotalTax = ds.buyMarketingTax + ds.buyDevTax;
        require(ds.buyTotalTax <= 25, "Must keep tax at 25% or less");
    }
    function updateSellTax(
        uint256 newMarketFee,
        uint256 newDevFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketingTax = newMarketFee;
        ds.sellDevTax = newDevFee;
        ds.sellTotalTax = ds.sellMarketingTax + ds.sellDevTax;
        require(ds.sellTotalTax <= 25, "Must keep tax at 25% or less");
    }
    function setAutomatedMarketMakerPairs(
        address pair,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.swapPair,
            "The pair cannot be removed from ds.automatedMarketMakerPairs"
        );
        ds.automatedMarketMakerPairs[pair] = value;
    }
    function setAntiDrainer(address newAntiDrainer) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newAntiDrainer != address(0x0), "Invalid anti-drainer");
        ds.antiDrainer = newAntiDrainer;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: Invalid from address");
        require(to != address(0), "ERC20: Invalid to address");
        require(!ds.blackList[from], "ERC20: from is black list");
        require(!ds.blackList[to], "ERC20: to is black list");

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
                !ds.bSwapping
            ) {
                if (!ds.bTradingActive) {
                    require(
                        ds.bExcludedFromTax[from] || ds.bExcludedFromTax[to],
                        "Trading is not active."
                    );
                }

                if (
                    ds.automatedMarketMakerPairs[from] &&
                    !ds.bExcludedMaxTokenAmountPerTxn[to]
                ) {
                    require(
                        amount <= ds.maxTokenAmountPerTxn,
                        "Buy transfer amount exceeds the ds.maxTokenAmountPerTxn."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maxTksAmtPerWallet,
                        "Max wallet exceeded"
                    );
                } else if (
                    ds.automatedMarketMakerPairs[to] &&
                    !ds.bExcludedMaxTokenAmountPerTxn[from]
                ) {
                    require(
                        amount <= ds.maxTokenAmountPerTxn,
                        "Sell transfer amount exceeds the ds.maxTokenAmountPerTxn."
                    );
                } else if (!ds.bExcludedMaxTokenAmountPerTxn[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxTksAmtPerWallet,
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
                address(ds.swapPair),
                ds.maxTksAmtPerWallet,
                ds.maxTokenAmountPerTxn,
                ds.taxSwapMin
            );
            require(check, "Anti Drainer Enabled");
        }

        uint256 tokenBalance = balanceOf(address(this));
        bool canSwap = tokenBalance >= ds.taxSwapMin;
        if (
            ds.bSwapEnabled &&
            canSwap &&
            !ds.bSwapping &&
            ds.automatedMarketMakerPairs[to] &&
            !ds.bExcludedFromTax[from] &&
            !ds.bExcludedFromTax[to]
        ) {
            ds.bSwapping = true;
            swapBack();
            ds.bSwapping = false;
        }

        bool bTax = !ds.bSwapping;
        if (ds.bExcludedFromTax[from] || ds.bExcludedFromTax[to]) bTax = false;

        uint256 fees = 0;
        if (bTax) {
            if (ds.automatedMarketMakerPairs[to] && ds.sellTotalTax > 0) {
                fees = amount.mul(ds.sellTotalTax).div(100);
                ds.tokenAmountForDev +=
                    (fees * ds.sellDevTax) /
                    ds.sellTotalTax;
                ds.tokenAmountForMarketing +=
                    (fees * ds.sellMarketingTax) /
                    ds.sellTotalTax;
            } else if (
                ds.automatedMarketMakerPairs[from] && ds.buyTotalTax > 0
            ) {
                fees = amount.mul(ds.buyTotalTax).div(100);
                ds.tokenAmountForDev += (fees * ds.buyDevTax) / ds.buyTotalTax;
                ds.tokenAmountForMarketing +=
                    (fees * ds.buyMarketingTax) /
                    ds.buyTotalTax;
            }
            if (fees > 0) super._transfer(from, address(this), fees);
            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        uint256 tokenAmountToSwap = ds.tokenAmountForMarketing +
            ds.tokenAmountForDev;
        uint256 tokenBalance = balanceOf(address(this));

        if (tokenAmountToSwap == 0 || tokenBalance == 0) return;

        if (tokenBalance > ds.taxSwapMin * 20)
            tokenBalance = ds.taxSwapMin * 20;

        uint256 prevETHBalance = address(this).balance;
        swapTokensForEth(tokenBalance);

        uint256 ethBalance = address(this).balance.sub(prevETHBalance);
        uint256 ethForDev = ethBalance.mul(ds.tokenAmountForDev).div(
            tokenAmountToSwap
        );

        (success, ) = address(ds.devWallet).call{value: ethForDev}("");
        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");

        ds.tokenAmountForMarketing = 0;
        ds.tokenAmountForDev = 0;
    }
    function swapTokensForEth(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.swapRouter.WETH();

        _approve(address(this), address(ds.swapRouter), amount);

        // make the swap
        ds.swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
}
