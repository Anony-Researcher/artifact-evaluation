// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "./TestLib.sol";
contract bidFacet {
    function bid() public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.value > ds.highestBid,
            "Need to be higher than highest bid"
        );
        // Refund the old leader, if it fails then revert
        require(
            payable(ds.frontRunner).send(ds.highestBid),
            "Failed to send Ether"
        );

        ds.frontRunner = msg.sender;
        ds.highestBid = msg.value;
    }
}
