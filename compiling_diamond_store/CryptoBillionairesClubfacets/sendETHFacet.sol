/*
 * The World's Most Exclusive Adult Club For The Crypto Elite!
 *
 * Website: https://cryptobillionaires.club
 * Telegram: https://t.me/cbcportal
 * Twitter: https://twitter.com/cbcp2e
 *
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract sendETHFacet is ERC20 {
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludedFromMaxWalletLimit(address indexed account, bool isExcluded);
    function sendETH(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (!ds.tradingEnabled) {
            require(
                ds._isExcludedFromRestrictions[from] ||
                    ds._isExcludedFromRestrictions[to],
                "Trading is not enabled"
            );
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= ds.swapTokensAtAmount;

        if (
            canSwap &&
            !ds.swapping &&
            !ds.automatedMarketMakerPairs[from] &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to]
        ) {
            ds.swapping = true;

            uint256 stakingShare = ds.stakingFeeOnBuy + ds.stakingFeeOnSell;
            uint256 marketingShare = ds.marketingFeeOnBuy +
                ds.marketingFeeOnSell;
            uint256 devShare = ds.devFeeOnBuy + ds.devFeeOnSell;
            uint256 totalShare = stakingShare + marketingShare + devShare;

            uint256 initialBalance = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = ds.uniswapV2Router.WETH();

            ds
                .uniswapV2Router
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    contractTokenBalance,
                    0, // accept any amount of ETH
                    path,
                    address(this),
                    block.timestamp
                );

            uint256 newBalance = address(this).balance - initialBalance;

            if (stakingShare > 0) {
                uint256 stakingAmount = (newBalance * stakingShare) /
                    totalShare;
                sendETH(payable(ds.stakingWallet), stakingAmount);
            }

            if (marketingShare > 0) {
                uint256 marketingAmount = (newBalance * marketingShare) /
                    totalShare;
                sendETH(payable(ds.marketingWallet), marketingAmount);
            }

            if (devShare > 0) {
                uint256 devAmount = (newBalance * devShare) / totalShare;
                sendETH(payable(ds.devWallet), devAmount);
            }
            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        if (
            (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) ||
            (from != ds.uniswapV2Pair && to != ds.uniswapV2Pair)
        ) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 _totalFees = 0;
            if (from == ds.uniswapV2Pair) {
                _totalFees = ds.buyFee;
            } else if (to == ds.uniswapV2Pair) {
                _totalFees = ds.sellFee;
            }

            if (_totalFees > 0) {
                uint256 fees = (amount * _totalFees) / 100;
                amount = amount - fees;
                super._transfer(from, address(this), fees);
            }
        }

        if (ds.maxWalletLimitEnabled) {
            if (
                ds._isExcludedFromMaxWalletLimit[from] == false &&
                ds._isExcludedFromMaxWalletLimit[to] == false &&
                to != ds.uniswapV2Pair
            ) {
                uint balance = balanceOf(to);
                require(
                    balance + amount <= maxWalletAmount(),
                    "MaxWallet: Recipient exceeds the maxWalletAmount"
                );
            }
        }

        super._transfer(from, to, amount);
    }
    function setEnableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingEnabled = true;
    }
    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        ds._isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAmount > totalSupply() / 100000,
            "SwapTokensAtAmount must be greater than 0.001% of total supply"
        );
        ds.swapTokensAtAmount = newAmount;
    }
    function setExcludeFromMaxWallet(
        address account,
        bool exclude
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromMaxWalletLimit[account] != exclude,
            "Account is already set to that state"
        );
        ds._isExcludedFromMaxWalletLimit[account] = exclude;
        emit ExcludedFromMaxWalletLimit(account, exclude);
    }
    function setEnableMaxWalletLimit(bool enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletLimitEnabled = enabled;
    }
    function maxWalletAmount() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (totalSupply() * ds.maxWalletLimitRate) / 1000;
    }
}
