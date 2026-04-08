// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/utils/Address.sol";

import "./TestLib.sol";
contract depositFacet {
    event Deposit(uint256 amount);
    function deposit() public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balances[msg.sender] += msg.value;
        ds.student_result[0] = address(0);
        emit Deposit(19);
    }
}
