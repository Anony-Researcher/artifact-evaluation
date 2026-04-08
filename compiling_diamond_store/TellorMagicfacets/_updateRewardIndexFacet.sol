// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _updateRewardIndexFacet {
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

    function _updateRewardIndex() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 currentTotalRewards = ds.tellorFlex.balanceOf(address(this));
        if (currentTotalRewards == 0 || ds.totalStakedAmount == 0) return;

        ds.rewardIndex +=
            (currentTotalRewards * MULTIPLIER) /
            ds.totalStakedAmount;
    }
    function submitValue(
        bytes32 _queryId,
        bytes calldata _value,
        uint256 _nonce,
        bytes calldata _queryData
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            block.timestamp - ds.tellorOracle.getTimeOfLastNewValue() > 60,
            "too few reward"
        );
        ds.tellorOracle.submitValue(_queryId, _value, _nonce, _queryData);

        _updateRewardIndex();
    }
}
