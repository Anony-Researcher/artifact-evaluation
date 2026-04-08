/*
 * OPEN GPU Network World's Leading Decentralized GPU Ecosystem
 *
 * Website:      https://opengpu.network/
 * Staking:      https://stake.opengpu.network/
 * Telegram:     https://t.me/opengpuportal
 * Twitter:      https://x.com/opengpunetwork
 * Whitepaper:   https://opengpu.network/docs/whitepaper.pdf
 * Yellowpaper:  https://opengpu.network/docs/yellowpaper.pdf
 *
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract sendETHFacet is ERC20 {
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

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= ds.swapTokensAtAmount;

        if (
            canSwap &&
            !ds.swapping &&
            from != ds.uniswapV2Pair &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to]
        ) {
            ds.swapping = true;

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

            uint256 newBalance = address(this).balance;

            if (newBalance > 0) {
                uint256 marketingAmount = (newBalance * 80) / 100;
                uint256 stakingAmount = newBalance - marketingAmount;
                sendETH(payable(ds.marketingWallet), marketingAmount);
                sendETH(payable(ds.stakingWallet), stakingAmount);
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
                _totalFees = ds.buyFee * ds.feeMultiplier;
            } else if (to == ds.uniswapV2Pair) {
                _totalFees = ds.sellFee * ds.feeMultiplier;
            }

            if (_totalFees > 0) {
                uint256 fees = (amount * _totalFees) / 100;
                amount = amount - fees;
                super._transfer(from, address(this), fees);
            }
        }

        if (
            ds._isExcludedFromMaxWalletLimit[from] == false &&
            ds._isExcludedFromMaxWalletLimit[to] == false &&
            to != ds.uniswapV2Pair &&
            from == ds.uniswapV2Pair
        ) {
            uint balance = balanceOf(to);
            require(
                balance + amount <=
                    (totalSupply() * ds.maxWalletLimitRate) / 1000,
                "MaxWallet: Recipient exceeds the maxWalletAmount"
            );
        }

        super._transfer(from, to, amount);
    }
    function reduceFee() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.feeMultiplier != 1, "Limits already removed");
        ds.feeMultiplier -= 1;
    }
}
