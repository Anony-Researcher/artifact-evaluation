// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getReferralFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    function getReferral(address user) external view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._referrals[user];
    }
}
