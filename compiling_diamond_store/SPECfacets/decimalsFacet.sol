/**
 *Submitted for verification at basescan.org on 2024-03-23
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is coffer {
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
}
