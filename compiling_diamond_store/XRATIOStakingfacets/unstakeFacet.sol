// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract unstakeFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    event UNSTAKE(address Staker, uint256 amount);
    function unstake(uint256 index) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds.stakersRecord[msg.sender][index].withdrawan,
            "already withdrawan"
        );
        require(
            !ds.stakersRecord[msg.sender][index].unstaked,
            "already unstaked"
        );
        require(index < ds.Stakers[msg.sender].stakeCount, "Invalid index");

        ds.stakersRecord[msg.sender][index].unstaked = true;
        uint256 planIndex = ds.stakersRecord[msg.sender][index].plan;
        uint256 penalty = ds
            .stakersRecord[msg.sender][index]
            .amount
            .mul(ds.Penalty[planIndex])
            .div(ds.unstakePercent);
        ds.stakeToken.transfer(ds.owner, penalty);
        ds.stakeToken.transfer(
            msg.sender,
            (ds.stakersRecord[msg.sender][index].amount).sub(penalty)
        );
        ds.totalUnStakedToken = ds.totalUnStakedToken.add(
            ds.stakersRecord[msg.sender][index].amount
        );
        ds.Stakers[msg.sender].totalUnStakedTokenUser = ds
            .Stakers[msg.sender]
            .totalUnStakedTokenUser
            .add(ds.stakersRecord[msg.sender][index].amount);
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

        emit UNSTAKE(msg.sender, ds.stakersRecord[msg.sender][index].amount);
    }
}
