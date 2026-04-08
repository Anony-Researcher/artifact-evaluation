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

contract SavingsBank {

    mapping(address => uint) public balances;

    // Update the `balances` mapping to include the new ETH deposited by msg.sender
    function addBalance() public payable {
        balances[msg.sender] += msg.value;
    }

    // Send ETH worth `balances[msg.sender]` back to msg.sender
    function withdraw() public {
        require(balances[msg.sender] > 0);
        (bool sent, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(sent, "Failed to send ether");
        // This code becomes unreachable because the contract's balance is drained
        // before user's balance could have been set to 0
        balances[msg.sender] = 0;
    }
}
