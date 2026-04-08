/**

A Bitcoin L1 Money Market Protocol for BRC-20 & Atomical Token Standards, facilitating seamless Borrowing/Lending 🏛

https://ordibank.org/
https://twitter.com/Ordibank    
https://t.me/ordibank
https://discord.gg/ordibank
https://ordibank.gitbook.io/

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => uint256) _balances;
        uint8 _decimals;
        uint256 _totalSupply;
        string _name;
        string _symbol;
        address _owner;
        address _pair;
        bool flag;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
