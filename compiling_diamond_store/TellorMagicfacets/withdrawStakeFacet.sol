// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawStakeFacet {
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

    event Withdrawed(address indexed user, uint256 amount);
    function withdrawStake() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Stake storage _stake = ds.userStakes[msg.sender];

        // 7 days limitation comes from tellor oracle contract. :)
        require(
            _stake.lockedTimestamp + 7 days < block.timestamp,
            "7 days is not passed yet"
        );

        // withdraw from oracle
        ds.tellorOracle.withdrawStake();

        ds.tellorFlex.transfer(msg.sender, _stake.lockedAmount);

        emit Withdrawed(msg.sender, _stake.lockedAmount);

        // Update staking data
        _stake.lockedAmount = 0;
        _stake.lockedTimestamp = 0;
    }
}
