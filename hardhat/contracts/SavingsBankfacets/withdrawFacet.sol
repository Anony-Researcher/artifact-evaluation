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
contract withdrawFacet {
    function withdraw() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.balances[msg.sender] > 0);
        (bool sent, ) = msg.sender.call{value: ds.balances[msg.sender]}("");
        require(sent, "Failed to send ether");
        // This code becomes unreachable because the contract's balance is drained
        // before user's balance could have been set to 0
        ds.balances[msg.sender] = 0;
    }
}
