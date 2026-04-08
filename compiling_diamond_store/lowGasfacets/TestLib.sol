// SPDX-License-Identifier: MIT

// Telegram: https://t.me/lowgastoken
// Deploy TX: https://etherscan.io/tx/0xecb717e81b492fb2aaa63e3d2534395be5213bd33db084a3a7a18c68bc767599
// Runs (Optimizer) : 38
// EVM Version to target: Default

pragma solidity ^0.8.25;

string constant name = "Low GAS";
string constant symbol = "LOW";
uint256 constant decimals = 18;
uint256 constant totalSupply = 30000000000000000000000;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) t;
        mapping(address => mapping(address => uint256)) z;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
