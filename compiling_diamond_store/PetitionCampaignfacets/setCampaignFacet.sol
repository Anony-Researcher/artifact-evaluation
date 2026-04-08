// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract setCampaignFacet {
    function setCampaign(string memory _campaign) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.campaign = _campaign;
    }
}
