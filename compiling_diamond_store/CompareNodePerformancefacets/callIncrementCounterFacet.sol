// SPDX-License-Identifier: MIT
// Reference: https://compare.chainstack.com/
// This contract is designed to compare node performance across different EVM chains.

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract callIncrementCounterFacet {
    function callIncrementCounter() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 dummyCounter = ds.counter;
        for (uint256 i = 0; i < INCREMENT_LOOP_COUNT; i++) {
            dummyCounter += 1;
        }
        return dummyCounter;
    }
}
