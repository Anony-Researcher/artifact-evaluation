// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract _transferFacet is Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    event SwapTokensForEthFailed(uint256 amount);
    event AddLiquidityFailed(uint256 ethAmount);
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "Can not transfer from the zero address");
        require(to != address(0), "Can not transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool localSwapping = ds.swapping;
        uint256 localTotalFees = ds.totalFees;

        bool canSwap = balanceOf(address(this)) >= ds.swapTokensAtAmount;

        if (
            canSwap &&
            !localSwapping &&
            !ds.automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner() &&
            localTotalFees > 0
        ) {
            swap();
        }

        bool takeFee = !localSwapping &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to] &&
            localTotalFees > 0;

        uint256 amountReceived = takeFee ? takeTaxes(from, amount) : amount;

        super._transfer(from, to, amountReceived);
    }
    function swap() private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amount = ds.swapTokensAtAmount;

        uint256 swapTokens = (amount * ds.liquidityShare) / 100;

        if (swapTokens > 0) swapAndLiquify(swapTokens);

        uint256 treasuryTokens = amount - swapTokens;

        if (treasuryTokens > 0) swapAndSendToTreasury(treasuryTokens);
    }
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance - initialBalance;

        if (newBalance == 0) return;

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        try
            ds
                .uniswapV2Router
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                )
        {} catch {
            emit SwapTokensForEthFailed(tokenAmount);
        }
    }
    function swapAndSendToTreasury(uint256 tokens) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokensToSwap = (tokens * ds.treasuryETHShare) / 100;
        uint256 tokensToTransfer = tokens - tokensToSwap;

        if (tokensToSwap == 0) return;

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokensToSwap);
        uint256 newBalance = address(this).balance - initialBalance;

        if (newBalance > 0) {
            (bool sent, ) = payable(ds.treasuryWallet).call{value: newBalance}(
                ""
            );
        }

        if (tokensToTransfer > 0) {
            super._transfer(address(this), ds.treasuryWallet, tokensToTransfer);
        }
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        try
            ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                address(0xdead),
                block.timestamp
            )
        {} catch {
            emit AddLiquidityFailed(ethAmount);
        }
    }
    function takeTaxes(address from, uint256 amount) private returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 localTotalFees = ds.totalFees;

        uint256 feeAmount = (amount * localTotalFees) / DENOMINATOR;
        super._transfer(from, address(this), feeAmount);

        return amount - feeAmount;
    }
}
