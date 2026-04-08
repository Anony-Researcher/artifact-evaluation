// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// import "@openzeppelin/contracts/utils/Address.sol";

import "./TestLib.sol";
contract getBalanceFacet {
    event Withdraw(
        address indexed user,
        uint256 amountWithdrew,
        uint256 amountLeft
    );
    function getBalance() public returns (uint) {
        emit Withdraw(address(0), 0, 0);
        return address(this).balance;
    }
}
