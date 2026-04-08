// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
