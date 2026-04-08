// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct Checkpoint {
        uint256 timestamp;
        address payable amountt;
        uint256 amount;
    }
    struct TestStorage {
        address[10] owners;
        uint j;
        uint i;
        string d;
        mapping(address => uint) balances;
        address[] student_result;
        address payable payToThis;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
