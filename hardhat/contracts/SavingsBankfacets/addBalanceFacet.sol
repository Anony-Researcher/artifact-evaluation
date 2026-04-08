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

import "./TestLib.sol";
contract addBalanceFacet {
    function addBalance() public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balances[msg.sender] += msg.value;
    }
}
