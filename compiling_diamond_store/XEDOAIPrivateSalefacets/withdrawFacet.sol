/**
 *Submitted for verification at Etherscan.io on 2024-04-05
 */

/**
 *Submitted for verification at Etherscan.io on 2024-03-21
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawFacet {
    function withdraw() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "You are not the ds.owner.");
        require(address(this).balance > 0, "The balance is zero.");

        uint256 balance = address(this).balance;
        ds.owner.transfer(balance);
    }
}
