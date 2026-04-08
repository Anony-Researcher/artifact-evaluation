// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract stakeFacet {
    using EnumerableSet for EnumerableSet.UintSet;

    modifier isStakeIdExist(address _user, uint256 _stakeId) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool isExist = ds._stakeIdsPerWallet[_user].contains(_stakeId);
        require(isExist, "You don't have stake with this stake id");
        _;
    }

    event Stake(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed stakeId
    );
    event Unstake(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed stakeId
    );
    event SetPeriod(uint256 indexed startDate, uint256 indexed finishDate);
    event Claim(
        address indexed user,
        uint256 indexed reward,
        uint256 indexed stakeId
    );
    function stake(uint256 _amount) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            block.timestamp >= ds.startDate && block.timestamp < ds.finishDate,
            "Cannot stake outside staking period"
        );

        ds.stakingToken.transferFrom(msg.sender, address(this), _amount);
        ds.totalStaked += _amount;
        ds.stakeCount++;

        uint256 stakeId = ds.stakeIdCount[msg.sender];
        ds._stakeIdsPerWallet[msg.sender].add(stakeId);
        ds.stakeInfo[msg.sender][stakeId] = TestLib.StakeInfo(
            stakeId,
            _amount,
            block.timestamp,
            0,
            ds.startDate,
            ds.finishDate
        );
        ds.stakeIdCount[msg.sender]++;

        emit Stake(msg.sender, _amount, stakeId);
    }
    function unstake(
        uint256 _id
    ) external nonReentrant isStakeIdExist(msg.sender, _id) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 penaltyAmount;
        uint256 amount = ds.stakeInfo[msg.sender][_id].amount;
        uint256 _finishDate = ds.stakeInfo[msg.sender][_id].finishPeriod;

        if (block.timestamp < _finishDate) {
            penaltyAmount = (amount * ds.penaltyPercentage) / 100;
            amount -= penaltyAmount;
            ds.totalPenalty += penaltyAmount;
        }

        _claimReward(msg.sender, _id);
        ds.stakingToken.transfer(msg.sender, amount);
        ds.stakeInfo[msg.sender][_id] = TestLib.StakeInfo(0, 0, 0, 0, 0, 0);
        ds._stakeIdsPerWallet[msg.sender].remove(_id);
        ds.totalStaked = ds.totalStaked - (amount + penaltyAmount);
        ds.stakeCount--;

        emit Unstake(msg.sender, amount + penaltyAmount, _id);
    }
    function claimReward(
        uint _id
    ) public nonReentrant isStakeIdExist(msg.sender, _id) {
        _claimReward(msg.sender, _id);
    }
    function setPenaltyPercentage(uint256 _percentage) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.penaltyPercentage = _percentage;
    }
    function setStakingRewardToken(
        address _stakingToken,
        address _rewardToken
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.stakingToken = IERC20(_stakingToken);
        ds.rewardToken = IERC20(_rewardToken);
    }
    function setPeriod(
        uint256 _startDate,
        uint256 _finishDate
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _startDate > block.timestamp,
            "Start date staking period must be greater than now"
        );
        require(
            _finishDate > _startDate,
            "Finish date must be greater than start date"
        );
        ds.startDate = _startDate;
        ds.finishDate = _finishDate;

        emit SetPeriod(_startDate, _finishDate);
    }
    function depositReward(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.rewardToken.transferFrom(msg.sender, address(this), _amount);
        ds.rewardCounter += _amount;
    }
    function withdrawReward(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.rewardToken.transfer(msg.sender, _amount);
    }
    function withdrawPenalty() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 penalty = ds.totalPenalty;
        ds.stakingToken.transfer(address(ds.stakingToken), penalty);
        ds.totalPenalty -= penalty;
    }
    function _claimReward(address _user, uint256 _id) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rewards = calculateReward(_user, _id);
        ds.rewardToken.transfer(_user, rewards);

        ds.stakeInfo[_user][_id].lastClaimDate = block.timestamp >
            ds.stakeInfo[_user][_id].finishPeriod
            ? ds.stakeInfo[_user][_id].finishPeriod
            : block.timestamp;

        emit Claim(_user, rewards, _id);
    }
    function calculateReward(
        address _user,
        uint256 _stakeId
    ) public view isStakeIdExist(_user, _stakeId) returns (uint256 rewards) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalReward = getTotalReward();
        uint256 stakingTokenDecimals = ds.stakingToken.decimals();
        uint256 rewardTokenDecimals = ds.rewardToken.decimals();
        uint256 decimalsDifference = stakingTokenDecimals > rewardTokenDecimals
            ? stakingTokenDecimals - rewardTokenDecimals
            : rewardTokenDecimals - stakingTokenDecimals;
        TestLib.StakeInfo memory _stakeInfo = ds.stakeInfo[_user][_stakeId];
        uint256 convertedAmount = stakingTokenDecimals > rewardTokenDecimals
            ? _stakeInfo.amount / 10 ** decimalsDifference
            : _stakeInfo.amount * 10 ** decimalsDifference;
        uint256 convertedTotalStaked = stakingTokenDecimals >
            rewardTokenDecimals
            ? ds.totalStaked / 10 ** decimalsDifference
            : ds.totalStaked * 10 ** decimalsDifference;
        uint256 lastClaim = _stakeInfo.lastClaimDate > _stakeInfo.stakeDate
            ? _stakeInfo.lastClaimDate
            : _stakeInfo.stakeDate;
        uint256 claimTime = block.timestamp > _stakeInfo.finishPeriod
            ? _stakeInfo.finishPeriod
            : block.timestamp;
        uint256 stakeDuration = claimTime - lastClaim;
        uint256 stakePeriod = _stakeInfo.finishPeriod - _stakeInfo.startPeriod;
        rewards = ((convertedAmount * stakeDuration * totalReward) /
            convertedTotalStaked /
            stakePeriod);
    }
    function getTotalReward() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.rewardCounter;
    }
}
