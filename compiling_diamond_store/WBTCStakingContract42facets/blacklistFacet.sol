// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract blacklistFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    event Blacklisted(address indexed user);
    function blacklist(address user) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._blacklisted[user], "User is already blacklisted.");
        ds._blacklisted[user] = true;

        emit Blacklisted(user);
    }
}
