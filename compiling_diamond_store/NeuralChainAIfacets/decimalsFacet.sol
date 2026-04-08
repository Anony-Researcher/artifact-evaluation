//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
