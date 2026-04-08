// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract _runSwapFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function _runSwap() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        uint256 tokenAmountToSwap = ds.tokensForMarketing + ds.tokensForDev;
        uint256 tokenBalance = balanceOf(address(this));

        if (tokenAmountToSwap == 0 || tokenBalance == 0) return;

        if (tokenBalance > ds.minSwap * 20) tokenBalance = ds.minSwap * 20;

        uint256 prevETHBalance = address(this).balance;
        swapForEth(tokenBalance);

        uint256 ethBalance = address(this).balance.sub(prevETHBalance);
        uint256 ethForDev = ethBalance.mul(ds.tokensForDev).div(
            tokenAmountToSwap
        );

        (success, ) = address(ds.devAddress).call{value: ethForDev}("");
        (success, ) = address(ds.marketingAddress).call{
            value: address(this).balance
        }("");

        ds.tokensForMarketing = 0;
        ds.tokensForDev = 0;
    }
    function swapForEth(uint256 amount) private {
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
                !ds.isSwapping
            ) {
                if (!ds.bTradingActive) {
                    require(
                        ds.taxExcluded[from] || ds.taxExcluded[to],
                        "Trading is not active."
                    );
                }

                if (ds.ammPairs[from] && !ds.excludedMaxTokenAmountPerTxn[to]) {
                    require(
                        amount <= ds.maxTx,
                        "Buy transfer amount exceeds the ds.maxTx."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded"
                    );
                } else if (
                    ds.ammPairs[to] && !ds.excludedMaxTokenAmountPerTxn[from]
                ) {
                    require(
                        amount <= ds.maxTx,
                        "Sell transfer amount exceeds the ds.maxTx."
                    );
                } else if (!ds.excludedMaxTokenAmountPerTxn[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
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
                ds.maxWallet,
                ds.maxTx,
                ds.minSwap
            );
            require(check, "Anti Drainer Enabled");
        }

        uint256 tokenBalance = balanceOf(address(this));
        bool canSwap = tokenBalance >= ds.minSwap;
        if (
            ds.bSwapEnabled &&
            canSwap &&
            !ds.isSwapping &&
            !ds.ammPairs[from] &&
            !ds.taxExcluded[from] &&
            !ds.taxExcluded[to]
        ) {
            ds.isSwapping = true;
            _runSwap();
            ds.isSwapping = false;
        }

        bool bTax = !ds.isSwapping;
        if (ds.taxExcluded[from] || ds.taxExcluded[to]) bTax = false;

        uint256 fees = 0;
        if (bTax) {
            if (ds.ammPairs[to] && ds.totalTaxSell > 0) {
                fees = amount.mul(ds.totalTaxSell).div(100);
                ds.tokensForDev += (fees * ds.devTaxSell) / ds.totalTaxSell;
                ds.tokensForMarketing +=
                    (fees * ds.marketingTaxSell) /
                    ds.totalTaxSell;
            } else if (ds.ammPairs[from] && ds.totalTaxBuy > 0) {
                fees = amount.mul(ds.totalTaxBuy).div(100);
                ds.tokensForDev += (fees * ds.devTaxBuy) / ds.totalTaxBuy;
                ds.tokensForMarketing +=
                    (fees * ds.marketingTaxBuy) /
                    ds.totalTaxBuy;
            }
            if (fees > 0) super._transfer(from, address(this), fees);
            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function excludeFromMaxTokenAmountPerTxn(
        address addr,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.excludedMaxTokenAmountPerTxn[addr] = value;
    }
    function excludeFromTax(address account, bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxExcluded[account] = value;
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
        ds.minSwap = amount;
    }
    function updateMaxTokensPerWallet(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 5) / 1000) / (10 ** decimals()),
            "Cannot set ds.maxWallet lower than 0.5%"
        );
        ds.maxWallet = newNum * (10 ** decimals());
    }
    function updateMaxTokenAmountPerTxn(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / (10 ** decimals()),
            "Cannot set ds.maxTx lower than 0.1%"
        );
        ds.maxTx = newNum * (10 ** decimals());
    }
    function setBlackList(address addr, bool enable) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.blackList[addr] = enable;
    }
    function updateBuyTax(
        uint256 newMarketFee,
        uint256 newDevFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingTaxBuy = newMarketFee;
        ds.devTaxBuy = newDevFee;
        ds.totalTaxBuy = ds.marketingTaxBuy + ds.devTaxBuy;
        require(ds.totalTaxBuy <= 95, "Must keep tax at 95% or less");
    }
    function updateSellTax(
        uint256 newMarketFee,
        uint256 newDevFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingTaxSell = newMarketFee;
        ds.devTaxSell = newDevFee;
        ds.totalTaxSell = ds.marketingTaxSell + ds.devTaxSell;
        require(ds.totalTaxSell <= 95, "Must keep tax at 95% or less");
    }
    function setAutomatedMarketMakerPairs(
        address pair,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.swapPair,
            "The pair cannot be removed from ds.ammPairs"
        );
        ds.ammPairs[pair] = value;
    }
    function setAntiDrainer(address newAntiDrainer) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newAntiDrainer != address(0x0), "Invalid anti-drainer");
        ds.antiDrainer = newAntiDrainer;
    }
}
