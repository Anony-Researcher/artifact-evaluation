// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getUserRewardsFacet {
    using SafeERC20 for IERC20;

    modifier inProgress() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds.isPaused,
            "TrestleStakingPool::initialized: staking is paused"
        );
        require(
            ds.startsAt <= block.timestamp,
            "TrestleStakingPool::initialized: staking has not started yet"
        );
        require(
            ds.endsAt > block.timestamp,
            "TrestleStakingPool::notFinished: staking has finished"
        );
        _;
    }
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "TrestleStakingPool::onlyOwner: not authorized"
        );
        _;
    }

    function getUserRewards(
        address _user,
        uint256 _stakeNumber
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 weightedAmount = ds.rewardsMultiplier.applyMultiplier(
            ds.userStakingInfo[_user][_stakeNumber].stakedAmount,
            ds.userStakingInfo[_user][_stakeNumber].duration
        );
        uint256 rewardsSinceLastUpdate = ((weightedAmount *
            (rewardPerToken() -
                ds.userStakingInfo[_user][_stakeNumber].rewardPerTokenPaid)) /
            (100 ** ds.rewardsTokenDecimals));
        return
            rewardsSinceLastUpdate +
            ds.userStakingInfo[_user][_stakeNumber].rewards;
    }
    function rewardPerToken() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.totalStaked == 0) {
            return ds.rewardPerTokenStored;
        }
        uint256 howLongSinceLastTime = lastTimeRewardApplicable() -
            ds.lastUpdateTime;
        return
            ds.rewardPerTokenStored +
            ((ds.rewardRatePerSec *
                howLongSinceLastTime *
                (100 ** ds.rewardsTokenDecimals)) / ds.totalWeightedStake);
    }
    function lastTimeRewardApplicable() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return block.timestamp < ds.endsAt ? block.timestamp : ds.endsAt;
    }
    function _updateReward(address _user, uint256 _stakeNumber) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.rewardPerTokenStored = rewardPerToken();
        ds.lastUpdateTime = lastTimeRewardApplicable();
        if (_user != address(0)) {
            ds.userStakingInfo[_user][_stakeNumber].rewards = getUserRewards(
                _user,
                _stakeNumber
            );
            ds.userStakingInfo[_user][_stakeNumber].rewardPerTokenPaid = ds
                .rewardPerTokenStored;
        }
    }
    function stake(
        uint256 _amount,
        TestLib.StakeTimeOptions _stakeTimeOption,
        uint256 _unstakeTime
    ) external nonReentrant inProgress {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_amount > 0, "TrestleStakingPool::stake: amount = 0");
        uint256 _minimumStakeTimestamp = _stakeTimeOption ==
            TestLib.StakeTimeOptions.Duration
            ? block.timestamp + _unstakeTime
            : _unstakeTime;
        require(
            _minimumStakeTimestamp > ds.startsAt,
            "TrestleStakingPool::stake: _minimumStakeTimestamp <= ds.startsAt"
        );
        require(
            _minimumStakeTimestamp > block.timestamp,
            "TrestleStakingPool::stake: _minimumStakeTimestamp <= block.timestamp"
        );

        uint256 _stakeDuration = _minimumStakeTimestamp - block.timestamp;

        _updateReward(address(0), 0);
        StakingInfo memory _stakingInfo = StakingInfo({
            stakedAmount: _amount,
            minimumStakeTimestamp: _minimumStakeTimestamp,
            duration: _stakeDuration,
            rewardPerTokenPaid: ds.rewardPerTokenStored,
            rewards: 0
        });
        ds.userStakingInfo[msg.sender].push(_stakingInfo);

        uint256 _stakeNumber = ds.userStakingInfo[msg.sender].length - 1;

        uint256 weightedStake = ds.rewardsMultiplier.applyMultiplier(
            _amount,
            _stakeDuration
        );
        ds.totalWeightedStake += weightedStake;
        ds.totalStaked += _amount;

        ds.stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _stakeNumber, _amount);
    }
    function unstake(
        uint256 _amount,
        uint256 _stakeNumber
    ) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_amount > 0, "TrestleStakingPool::unstake: amount = 0");
        require(
            _amount <=
                ds.userStakingInfo[msg.sender][_stakeNumber].stakedAmount,
            "TrestleStakingPool::unstake: not enough balance"
        );

        _updateReward(msg.sender, _stakeNumber);

        uint256 currentWeightedStake = ds.rewardsMultiplier.applyMultiplier(
            ds.userStakingInfo[msg.sender][_stakeNumber].stakedAmount,
            ds.userStakingInfo[msg.sender][_stakeNumber].duration
        );
        ds.totalWeightedStake -= currentWeightedStake;
        ds.totalStaked -= _amount;

        uint256 penaltyFee = 0;
        if (
            block.timestamp <
            ds.userStakingInfo[msg.sender][_stakeNumber].minimumStakeTimestamp
        ) {
            penaltyFee = ds.penaltyFeeCalculator.calculate(
                _amount,
                ds.userStakingInfo[msg.sender][_stakeNumber].duration,
                address(this)
            );
            if (penaltyFee > _amount) {
                penaltyFee = _amount;
            }
        }

        ds.userStakingInfo[msg.sender][_stakeNumber].stakedAmount -= _amount;

        if (ds.userStakingInfo[msg.sender][_stakeNumber].stakedAmount == 0) {
            _claimRewards(msg.sender, _stakeNumber);
            // remove the staking info from array
            ds.userStakingInfo[msg.sender][_stakeNumber] = ds.userStakingInfo[
                msg.sender
            ][ds.userStakingInfo[msg.sender].length - 1];
            ds.userStakingInfo[msg.sender].pop();
        } else {
            // update the weighted stake
            uint256 newWeightedStake = ds.rewardsMultiplier.applyMultiplier(
                ds.userStakingInfo[msg.sender][_stakeNumber].stakedAmount,
                ds.userStakingInfo[msg.sender][_stakeNumber].duration
            );
            ds.totalWeightedStake += newWeightedStake;
        }

        if (penaltyFee > 0) {
            ds.stakingToken.safeTransfer(BURN_ADDRESS, penaltyFee);
            _amount -= penaltyFee;
        }
        ds.stakingToken.safeTransfer(msg.sender, _amount);
        emit Unstaked(msg.sender, _stakeNumber, _amount);
    }
    function claimRewards(uint256 _stakeNumber) external nonReentrant {
        _updateReward(msg.sender, _stakeNumber);
        _claimRewards(msg.sender, _stakeNumber);
    }
    function initializeStaking(
        uint256 _startsAt,
        uint256 _rewardsDuration,
        uint256 _amount
    ) external nonReentrant onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _startsAt > block.timestamp,
            "TrestleStakingPool::initializeStaking: _startsAt must be in the future"
        );
        require(
            _rewardsDuration > 0,
            "TrestleStakingPool::initializeStaking: _rewardsDuration = 0"
        );
        require(
            _amount > 0,
            "TrestleStakingPool::initializeStaking: _amount = 0"
        );
        require(
            ds.startsAt == 0,
            "TrestleStakingPool::initializeStaking: staking already started"
        );

        _updateReward(address(0), 0);

        ds.rewardsDuration = _rewardsDuration;
        ds.startsAt = _startsAt;
        ds.endsAt = _startsAt + _rewardsDuration;

        // add the amount to the pool
        uint256 initialAmount = ds.rewardsToken.balanceOf(address(this));
        ds.rewardsToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 actualAmount = ds.rewardsToken.balanceOf(address(this)) -
            initialAmount;
        ds.totalRewards = actualAmount;
        ds.rewardRatePerSec = actualAmount / _rewardsDuration;

        // set the staking to in progress
        ds.isPaused = false;
    }
    function _claimRewards(address _user, uint256 _stakeNumber) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 reward = ds.userStakingInfo[_user][_stakeNumber].rewards;

        if (reward > 0) {
            ds.userStakingInfo[_user][_stakeNumber].rewards = 0;
            ds.rewardsToken.safeTransfer(_user, reward);
            emit RewardPaid(_user, _stakeNumber, reward);
        }
    }
}
