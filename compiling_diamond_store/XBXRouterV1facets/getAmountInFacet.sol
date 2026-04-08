// Sources flattened with hardhat v2.13.0 https://hardhat.org

// File contracts/interfaces/uniswap/IUniswapV2Factory.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
import "./TestLib.sol";
contract getAmountInFacet {
    using SafeMath for uint;

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) public pure virtual returns (uint amountIn) {
        return XBXLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }
}
