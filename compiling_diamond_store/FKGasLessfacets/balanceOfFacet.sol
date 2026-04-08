/**
 *Submitted for verification at Etherscan.io on 2024-03-23
 */

// SPDX-License-Identifier: MIT
//Telegram: fuck your mom gasless dev
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.b[account];
    }
}
