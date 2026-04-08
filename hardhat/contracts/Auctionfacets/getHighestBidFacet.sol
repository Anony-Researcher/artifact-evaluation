// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "./TestLib.sol";
contract getHighestBidFacet {
    function getHighestBid() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.highestBid;
    }
}
