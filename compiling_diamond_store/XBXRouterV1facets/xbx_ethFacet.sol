// Sources flattened with hardhat v2.13.0 https://hardhat.org

// File contracts/interfaces/uniswap/IUniswapV2Factory.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.6;
import "./TestLib.sol";
contract xbx_ethFacet {
    using SafeMath for uint;

    function xbx_eth(address to) public payable {
        require(msg.value > 0, "XBXRouter: INSUFFICIENT_ETH_AMOUNT");
        TransferHelper.safeTransferETH(to, ((msg.value * 199) / 200));
    }
}
