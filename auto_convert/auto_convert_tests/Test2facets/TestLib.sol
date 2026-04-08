// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/utils/Address.sol";

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct Checkpoint {
        uint256 timestamp;
        address payable amountt;
        uint256 amount;
    }
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }
    struct TestStorage {
        uint256 MAX_LOCK;
        uint256 BASE_MULTIPLIER;
        address[10] owners;
        uint j;
        uint i;
        string d;
        mapping(address => uint) balances;
        address[] student_result;
        address payable payToThis;
        Status status;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
