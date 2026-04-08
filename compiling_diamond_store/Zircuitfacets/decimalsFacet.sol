// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
