// SPDX-License-Identifier: MIT
// Reference: https://compare.chainstack.com/
// This contract is designed to compare node performance across different EVM chains.

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract writeComputeCounterFacet {
    function writeComputeCounter() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 sum = 0;
        for (uint256 i = 0; i < COMPUTE_LOOP_COUNT; i++) {
            sum += i * ds.counter;
        }
        ds.lastComputed = sum;
    }
}
