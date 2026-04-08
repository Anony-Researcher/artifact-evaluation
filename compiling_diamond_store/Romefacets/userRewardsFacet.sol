// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract userRewardsFacet {
    using SafeMath for uint256;

    function userRewards() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalrewards = 0;
        for (uint256 i = 0; i < ds.userInfo[msg.sender].length; i++) {
            uint256 mins = 0;
            uint256 balance = ds.stakingBalance[msg.sender];
            uint256 divisor = 100000;
            if (
                block.timestamp >=
                ds.userInfo[msg.sender][i].stakeTime + LOCK_PERIOD
            ) {
                mins = (((ds.startDate + LOCK_PERIOD) -
                    ds.userInfo[msg.sender][i].stakeTime) / 60);
            } else {
                if (
                    ds.userInfo[msg.sender][i].stakeTime >
                    (ds.startDate + LOCK_PERIOD)
                ) {
                    mins = 0;
                } else {
                    mins = ((block.timestamp -
                        ds.userInfo[msg.sender][i].stakeTime) / 60);
                }
            }
            uint256 hoursmultiplier = 365 * 24 * 60;
            uint256 custommultiplier = ds.defaultAPY * divisor;
            uint256 totalreward = SafeMath.div(
                custommultiplier,
                hoursmultiplier
            );
            uint256 reward = (balance / 100) * totalreward;
            uint256 rew = SafeMath.div(reward, divisor) * mins;
            totalrewards += rew;
        }
        return totalrewards;
    }
}
