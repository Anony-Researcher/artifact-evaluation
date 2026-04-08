// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract unblacklistFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    event Unblacklisted(address indexed user);
    function unblacklist(address user) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._blacklisted[user], "User is not blacklisted.");
        ds._blacklisted[user] = false;

        emit Unblacklisted(user);
    }
}
