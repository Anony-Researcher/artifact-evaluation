// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract getPendingRewardByStakerFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function getPendingRewardByStaker(
        address _stakerAddress
    ) public onlyOwner returns (uint256 _pendingReward) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _pendingReward = ds.tellorFlex.getPendingRewardByStaker(_stakerAddress);
    }
}
