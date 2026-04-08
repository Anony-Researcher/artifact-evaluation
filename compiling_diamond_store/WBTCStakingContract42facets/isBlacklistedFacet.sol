// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract isBlacklistedFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    function isBlacklisted(address user) external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._blacklisted[user];
    }
}
