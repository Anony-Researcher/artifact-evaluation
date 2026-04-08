// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

contract Auction {
    address frontRunner;
    uint256 public highestBid;

    function bid() public payable {
        require(msg.value > highestBid, "Need to be higher than highest bid");
        // Refund the old leader, if it fails then revert
        require(payable(frontRunner).send(highestBid), "Failed to send Ether");

        frontRunner = msg.sender;
        highestBid = msg.value;
    }

    function getHighestBid() public view returns (uint256) {
        return highestBid;
    }
}
