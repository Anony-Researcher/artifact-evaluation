// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract stakeFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    event STAKE(address Staker, uint256 amount);
    function stake(uint256 amount, uint256 planIndex) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(planIndex >= 0 && planIndex <= 2, "Invalid Time Period");
        require(amount >= 0, "stake more than 0");

        if (!ds.Stakers[msg.sender].alreadyExists) {
            ds.Stakers[msg.sender].alreadyExists = true;
            ds.StakersID[ds.totalStakers] = msg.sender;
            ds.totalStakers++;
        }

        ds.stakeToken.transferFrom(msg.sender, address(this), amount);

        uint256 index = ds.Stakers[msg.sender].stakeCount;
        ds.Stakers[msg.sender].totalStakedTokenUser = ds
            .Stakers[msg.sender]
            .totalStakedTokenUser
            .add(amount);
        ds.totalStakedToken = ds.totalStakedToken.add(amount);
        ds.stakersRecord[msg.sender][index].withdrawtime = block.timestamp.add(
            ds.Duration[planIndex]
        );
        ds.stakersRecord[msg.sender][index].staketime = block.timestamp;
        ds.stakersRecord[msg.sender][index].amount = amount;
        ds.stakersRecord[msg.sender][index].reward = amount
            .mul(ds.Bonus[planIndex])
            .div(ds.percentDivider);
        ds.stakersRecord[msg.sender][index].persecondreward = ds
            .stakersRecord[msg.sender][index]
            .reward
            .div(ds.Duration[planIndex]);
        ds.stakersRecord[msg.sender][index].plan = planIndex;
        ds.Stakers[msg.sender].stakeCount++;
        ds.userStakedPerPlan[msg.sender][planIndex] = ds
        .userStakedPerPlan[msg.sender][planIndex].add(amount);
        ds.totalStakedPerPlan[planIndex] = ds.totalStakedPerPlan[planIndex].add(
            amount
        );
        ds.totalStakersPerPlan[planIndex]++;

        emit STAKE(msg.sender, amount);
    }
}
