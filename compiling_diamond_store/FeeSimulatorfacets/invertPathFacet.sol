// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;
import "./TestLib.sol";
contract invertPathFacet {
    function invertPath(
        address[] calldata _path
    ) public pure returns (address[] memory) {
        address[] memory invertedPath = new address[](_path.length);
        for (uint256 i = 0; i < _path.length; i++) {
            invertedPath[i] = _path[_path.length - 1 - i];
        }
        return invertedPath;
    }
    function simulateGetFeeData(
        uint256 _amountIn,
        address[] calldata _path
    ) external payable returns (uint256[6] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_path[0] == ds.uniswapV2.WETH())
            IWETH(ds.uniswapV2.WETH()).deposit{value: msg.value}();
        IERC20 baseToken = IERC20(_path[0]);
        IERC20 targetToken = IERC20(_path[_path.length - 1]);
        baseToken.approve(address(ds.uniswapV2), ds.MAX_INT);
        targetToken.approve(address(ds.uniswapV2), ds.MAX_INT);

        // Buy token
        uint256 initialBalance = targetToken.balanceOf(address(this));
        uint256 expectedBalance1 = ds.uniswapV2.getAmountsOut(_amountIn, _path)[
            _path.length - 1
        ];
        uint256 usedGas = gasleft();
        ds.uniswapV2.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            0,
            _path,
            address(this),
            block.timestamp + 5 minutes
        );
        uint256 usedGas1 = usedGas - gasleft();
        uint256 finalBalance = targetToken.balanceOf(address(this));
        uint256 finalAmount1 = finalBalance - initialBalance;

        // Sell token
        uint256 initialBalance2 = baseToken.balanceOf(address(this));
        address[] memory invertedPath = invertPath(_path);
        uint256 expectedBalance2 = ds.uniswapV2.getAmountsOut(
            finalAmount1,
            invertedPath
        )[invertedPath.length - 1];
        uint256 usedGasSecond = gasleft();
        ds.uniswapV2.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            finalAmount1,
            0,
            invertedPath,
            address(this),
            block.timestamp + 5 minutes
        );
        uint256 usedGas2 = usedGasSecond - gasleft();
        uint256 finalBalance2 = baseToken.balanceOf(address(this));
        uint256 finalAmount2 = finalBalance2 - initialBalance2;

        return [
            finalAmount1,
            expectedBalance1,
            finalAmount2,
            expectedBalance2,
            usedGas1,
            usedGas2
        ];
    }
}
