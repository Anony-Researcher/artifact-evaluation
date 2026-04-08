// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract toggleClaimActiveFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not ds.owner");
        _;
    }

    function toggleClaimActive() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.claimActive = !ds.claimActive;
    }
}
