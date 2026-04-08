/*

Tao Inscriptions · Eternals
Enabling inscriptions in bittensor with $TAOIN

Twitter:        https://twitter.com/TaoInscriptions

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;
import "./TestLib.sol";
contract _transferFacet is ERC20, Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            balanceOf(from) >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (
            (from == ds.uniswapV2Pair || to == ds.uniswapV2Pair) &&
            !ds.inSwapAndLiquify
        ) {
            if (from != ds.uniswapV2Pair) {
                uint256 contractLiquidityBalance = balanceOf(address(this)) -
                    ds._marketingReserves;
                if (
                    contractLiquidityBalance >=
                    ds._numTokensSellToAddToLiquidity
                ) {
                    _swapAndLiquify(ds._numTokensSellToAddToLiquidity);
                }
                if ((ds._marketingReserves) >= ds._numTokensSellToAddToETH) {
                    _swapTokensForEth(ds._numTokensSellToAddToETH);
                    ds._marketingReserves -= ds._numTokensSellToAddToETH;
                    bool sent = payable(ds.marketingWallet).send(
                        address(this).balance
                    );
                    require(sent, "Failed to send ETH");
                }
            }

            uint256 transferAmount;
            if (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) {
                transferAmount = amount;
            } else {
                require(
                    amount <= ds.maxTxAmount,
                    "ERC20: transfer amount exceeds the max transaction amount"
                );
                if (from == ds.uniswapV2Pair) {
                    require(
                        (amount + balanceOf(to)) <= ds.maxWalletAmount,
                        "ERC20: balance amount exceeded max wallet amount limit"
                    );
                }

                uint256 marketingShare = ((amount * ds.taxForMarketing) / 100);
                uint256 liquidityShare = ((amount * ds.taxForLiquidity) / 100);
                transferAmount = amount - (marketingShare + liquidityShare);
                ds._marketingReserves += marketingShare;

                super._transfer(
                    from,
                    address(this),
                    (marketingShare + liquidityShare)
                );
            }
            super._transfer(from, to, transferAmount);
        } else {
            super._transfer(from, to, amount);
        }
    }
    function changeMarketingWallet(
        address newWallet
    ) public onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingWallet = newWallet;
        return true;
    }
    function changeTaxForLiquidityAndMarketing(
        uint256 _taxForLiquidity,
        uint256 _taxForMarketing
    ) public onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            (_taxForLiquidity + _taxForMarketing) <= 100,
            "ERC20: total tax must not be greater than 100"
        );
        ds.taxForLiquidity = _taxForLiquidity;
        ds.taxForMarketing = _taxForMarketing;

        return true;
    }
    function changeMaxTxAmount(
        uint256 _maxTxAmount
    ) public onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTxAmount = _maxTxAmount;

        return true;
    }
    function changeMaxWalletAmount(
        uint256 _maxWalletAmount
    ) public onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletAmount = _maxWalletAmount;

        return true;
    }
    function _swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = (contractTokenBalance / 2);
        uint256 otherHalf = (contractTokenBalance - half);

        uint256 initialBalance = address(this).balance;

        _swapTokensForEth(half);

        uint256 newBalance = (address(this).balance - initialBalance);

        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    function _swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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
            (block.timestamp + 300)
        );
    }
    function _addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount
    ) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }
}
