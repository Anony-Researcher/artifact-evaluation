// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import "./TestLib.sol";

contract getBalanceFacet {
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
