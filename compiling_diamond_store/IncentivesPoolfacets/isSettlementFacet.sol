// File: @openzeppelin/contracts/utils/math/SafeCast.sol

/// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract isSettlementFacet {
    using SafeERC20 for IERC20;
    using AddressLib for Address;
    using AddressSet for AddressSet.Data;

    modifier onlyManager() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (msg.sender != ds._manager) revert OnlyManager();
        _;
    }
    modifier onlySolvers() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._solvers.contains(msg.sender)) revert OnlySolvers();
        _;
    }

    function isSettlement(address settlement) external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._settlements.contains(settlement);
    }
}
