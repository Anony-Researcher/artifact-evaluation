// SPDX-License-Identifier: MIT

/* 
Generic taxable token with native currency and custom token recovery features.

Contract created by: Service Bridge https://serbridge.com/
SerBridge LinkTree with project updates https://linktr.ee/serbridge
*/

pragma solidity 0.8.17;
import "./TestLib.sol";
contract addLiquidityFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV3Router), tokenAmount);

        ds.uniswapV3Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(0xdead),
            block.timestamp
        );
    }
}
