// Sources flattened with hardhat v2.13.0 https://hardhat.org

// File contracts/interfaces/uniswap/IUniswapV2Factory.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
import "./TestLib.sol";
contract _swapFacet {
    using SafeMath for uint;

    function _swap(
        uint[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = XBXLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0
                ? (uint(0), amountOut)
                : (amountOut, uint(0));
            address to = i < path.length - 2
                ? XBXLibrary.pairFor(ds.factory, output, path[i + 2])
                : _to;
            IUniswapV2Pair(XBXLibrary.pairFor(ds.factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }
    function xbx_swap(
        address tokenOut,
        uint256 tipAmount,
        uint256 amountOut
    ) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.value > tipAmount, "Insufficient eth amount.");
        if (tipAmount > 0) {
            block.coinbase.transfer(tipAmount);
        }

        uint256 ethAmount = ((msg.value - tipAmount) * 99) / 100;
        address[] memory path;
        path = new address[](2);
        path[0] = ds.WETH;
        path[1] = tokenOut;

        uint[] memory amounts;
        amounts = XBXLibrary.getAmountsOut(ds.factory, ethAmount, path);
        if ((amountOut != 0) && (amounts[1] > amountOut)) {
            amounts = XBXLibrary.getAmountsIn(ds.factory, amountOut, path);
        }
        require(amounts[1] > 0, "Insufficient token amount.");
        IWETH(ds.WETH).deposit{value: amounts[0]}();
        assert(
            IWETH(ds.WETH).transfer(
                XBXLibrary.pairFor(ds.factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, msg.sender);
        // refund dust eth, if any
        if (ethAmount > amounts[0])
            TransferHelper.safeTransferETH(msg.sender, ethAmount - amounts[0]);
    }
    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) public view virtual returns (uint[] memory amounts) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return XBXLibrary.getAmountsOut(ds.factory, amountIn, path);
    }
    function xbx_buy(address tokenOut) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethAmount = (msg.value * 199) / 200;
        address[] memory path;
        path = new address[](2);
        path[0] = ds.WETH;
        path[1] = tokenOut;

        uint[] memory amounts = XBXLibrary.getAmountsOut(
            ds.factory,
            ethAmount,
            path
        );
        require(
            amounts[amounts.length - 1] >= 0,
            "XBXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWETH(ds.WETH).deposit{value: amounts[0]}();
        assert(
            IWETH(ds.WETH).transfer(
                XBXLibrary.pairFor(ds.factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, msg.sender);
    }
    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) public view virtual returns (uint[] memory amounts) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return XBXLibrary.getAmountsIn(ds.factory, amountOut, path);
    }
}
