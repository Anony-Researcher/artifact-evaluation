// SPDX-License-Identifier: MIT
//Telegram: https://t.me/gaslesstoken
pragma solidity ^0.8.25;

uint256 constant totalSupply = 10000000000000000000000;
string constant name = "Gasless";
string constant symbol = "Gasless";
uint8 constant decimals = 18;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) b;
        mapping(address => mapping(address => uint256)) a;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
