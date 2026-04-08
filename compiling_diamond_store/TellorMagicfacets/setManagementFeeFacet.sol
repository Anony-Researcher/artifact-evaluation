// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract setManagementFeeFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "Only contract ds.owner can call this function"
        );
        _;
    }
    modifier whenStakeNotPaused() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.stakePaused, "TestLib.Stake is paused");
        _;
    }

    function setManagementFee(uint256 _fee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_fee <= MANAGEMENT_FEE_CAP, "Too high");
        ds.managementFee = _fee;
    }
}
