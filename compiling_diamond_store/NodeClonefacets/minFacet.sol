// SPDX-License-Identifier: MIT

/******************************************
 *
 * Node Clone
 * Multi-chain Scalable Node Infrastructure
 *
 * Learn more on Telegram:
 * https://t.me/NodeClone
 *
 ******************************************/

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract minFacet is ERC20 {
    using SafeMath for uint256;

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a < b) ? a : b;
    }
}
