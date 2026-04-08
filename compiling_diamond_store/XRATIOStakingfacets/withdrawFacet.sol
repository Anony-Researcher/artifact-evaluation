// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract withdrawFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    function withdraw(uint256 index) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds.stakersRecord[msg.sender][index].withdrawan,
            "already withdrawan"
        );
        require(
            !ds.stakersRecord[msg.sender][index].unstaked,
            "already unstaked"
        );
        require(
            ds.stakersRecord[msg.sender][index].withdrawtime < block.timestamp,
            "cannot withdraw before stake duration"
        );
        require(index < ds.Stakers[msg.sender].stakeCount, "Invalid index");

        ds.stakersRecord[msg.sender][index].withdrawan = true;
        ds.stakeToken.transfer(
            msg.sender,
            ds.stakersRecord[msg.sender][index].amount
        );
        ds.stakeToken.transferFrom(
            ds.owner,
            msg.sender,
            ds.stakersRecord[msg.sender][index].reward
        );
        ds.totalWithdrawanToken = ds.totalWithdrawanToken.add(
            ds.stakersRecord[msg.sender][index].amount
        );
        ds.totalClaimedRewardToken = ds.totalClaimedRewardToken.add(
            ds.stakersRecord[msg.sender][index].reward
        );
        ds.Stakers[msg.sender].totalWithdrawanTokenUser = ds
            .Stakers[msg.sender]
            .totalWithdrawanTokenUser
            .add(ds.stakersRecord[msg.sender][index].amount);
        ds.Stakers[msg.sender].totalClaimedRewardTokenUser = ds
            .Stakers[msg.sender]
            .totalClaimedRewardTokenUser
            .add(ds.stakersRecord[msg.sender][index].reward);
        uint256 planIndex = ds.stakersRecord[msg.sender][index].plan;
        ds.userStakedPerPlan[msg.sender][planIndex] = ds
        .userStakedPerPlan[msg.sender][planIndex].sub(
                ds.stakersRecord[msg.sender][index].amount,
                "user stake"
            );
        ds.totalStakedPerPlan[planIndex] = ds.totalStakedPerPlan[planIndex].sub(
            ds.stakersRecord[msg.sender][index].amount,
            "total stake"
        );
        ds.totalStakersPerPlan[planIndex]--;

        emit WITHDRAW(
            msg.sender,
            ds.stakersRecord[msg.sender][index].reward.add(
                ds.stakersRecord[msg.sender][index].amount
            )
        );
    }
}
