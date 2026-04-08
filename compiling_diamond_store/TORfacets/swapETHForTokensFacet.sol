// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import "./TestLib.sol";
contract swapETHForTokensFacet {
    using Address for address;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    event SwapETHForTokens(uint256 amountIn, address[] path);
    function swapETHForTokens(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = ds.WETH;
        path[1] = address(this);
        // make the swap
        ds.uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            ds.swapOutput, // accept any amount of Tokens
            path,
            deadWallet, // Burn address
            block.timestamp + 300
        );
        emit SwapETHForTokens(amount, path);
    }
}
