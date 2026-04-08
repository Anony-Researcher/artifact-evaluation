/**
 *Submitted for verification at Etherscan.io on 2024-04-05
 */

/**
 *Submitted for verification at Etherscan.io on 2024-03-21
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract buyTokensFacet {
    event Purchase(address indexed buyer, uint256 ethAmount);
    function buyTokens() public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Record the buyer's purchase.
        ds.buyers[msg.sender] += msg.value;

        // Emit an event for the purchase
        emit Purchase(msg.sender, msg.value);
    }
}
