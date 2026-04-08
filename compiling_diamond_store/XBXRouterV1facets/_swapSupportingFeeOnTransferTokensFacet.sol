// Sources flattened with hardhat v2.13.0 https://hardhat.org

// File contracts/interfaces/uniswap/IUniswapV2Factory.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
import "./TestLib.sol";
contract _swapSupportingFeeOnTransferTokensFacet {
    using SafeMath for uint;

    function _swapSupportingFeeOnTransferTokens(
        address[] memory path,
        address _to
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = XBXLibrary.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(
                XBXLibrary.pairFor(ds.factory, input, output)
            );
            uint amountInput;
            uint amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1, ) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(
                    reserveInput
                );
                amountOutput = XBXLibrary.getAmountOut(
                    amountInput,
                    reserveInput,
                    reserveOutput
                );
            }
            (uint amount0Out, uint amount1Out) = input == token0
                ? (uint(0), amountOutput)
                : (amountOutput, uint(0));
            address to = i < path.length - 2
                ? XBXLibrary.pairFor(ds.factory, output, path[i + 2])
                : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure virtual returns (uint amountOut) {
        return XBXLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }
    function xbx_sell(address tokenOut, uint256 amountIn) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20 token = IERC20(address(tokenOut));
        require(
            token.allowance(msg.sender, address(this)) > amountIn,
            "Not enough allowance."
        );

        address[] memory path;
        path = new address[](2);
        path[0] = address(tokenOut);
        path[1] = ds.WETH;

        require(path[path.length - 1] == ds.WETH, "XBXRouter: INVALID_PATH");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            XBXLibrary.pairFor(ds.factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(ds.WETH).balanceOf(address(this));
        require(amountOut >= 0, "XBXRouter: INSUFFICIENT_OUTPUT_AMOUNT");
        IWETH(ds.WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(msg.sender, (amountOut * 199) / 200);
    }
}
