// SPDX-License-Identifier: GPL-3.0

// pragma solidity >=0.8.1 <0.9.0;

//contract SavingsBank {
//    mapping(address => uint) public balances;

//    function deposit() public payable {
//        balances[msg.sender] += msg.value;
//    }

//    function withdraw() public {
//        uint bal = balances[msg.sender];
//        require(bal > 0);

//        (bool sent, ) = msg.sender.call{value: bal}("");
//        require(sent, "Failed to send Ether");

//        balances[msg.sender] = 0;
//    }

// Helper function to check the balance of this contract
//    function getBalance() public view returns (uint) {
//        return address(this).balance;
//    }
//}

pragma solidity ^0.8.4;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint) balances;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
