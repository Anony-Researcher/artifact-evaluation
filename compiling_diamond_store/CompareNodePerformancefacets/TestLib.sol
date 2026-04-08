// SPDX-License-Identifier: MIT
// Reference: https://compare.chainstack.com/
// This contract is designed to compare node performance across different EVM chains.

pragma solidity ^0.8.0;

uint256 constant INCREMENT_LOOP_COUNT = 206;
uint256 constant COMPUTE_LOOP_COUNT = 103;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        uint256 counter;
        uint256 lastComputed;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
