// SPDX-License-Identifier: MIT

// Website: https://tensorspace.cloud/

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract minFacet is ERC20 {
    using SafeMath for uint256;

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}
