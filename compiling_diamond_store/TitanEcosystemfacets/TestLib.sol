/**
 *Submitted for verification at Etherscan.io on 2023-10-31
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        address owner;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        uint256 totalSupply;
        string name;
        string symbol;
        uint8 decimals;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
