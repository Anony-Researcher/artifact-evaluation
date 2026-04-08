//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract depositFacet {
    event Deposit(address indexed user, uint256 indexed poolId, uint256 amount);
    event Withdraw(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount
    );
    event HarvestRewards(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount
    );
    function deposit(uint256 _poolId, uint256 _amount) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_amount >= 1000 * 1e18, "Minimum deposit amount is 1000 LNQ");
        require(
            _poolId >= 0 && _poolId < ds.pools.length,
            "TestLib.Pool does not exist"
        );
        TestLib.Pool storage pool = ds.pools[_poolId];
        TestLib.PoolStaker storage staker = ds.poolStakers[_poolId][msg.sender];
        // Update pool stakers
        updatePoolRewards(_poolId);
        // Update current staker
        if (staker.amount > 0) {
            staker.rewards =
                staker.rewards +
                (staker.amount * pool.accumulatedRewardsPerShare) /
                REWARDS_PRECISION -
                staker.rewardDebt;
        } else {
            staker.startTime = block.timestamp;
            staker.endTime = block.timestamp + ds.lockTime[_poolId] * 1 days;
        }
        staker.amount = staker.amount + _amount;
        staker.rewardDebt =
            (staker.amount * pool.accumulatedRewardsPerShare) /
            REWARDS_PRECISION;

        // Update pool
        pool.tokensStaked = pool.tokensStaked + _amount;
        // Deposit tokens
        emit Deposit(msg.sender, _poolId, _amount);
        ds.LNQToken.transferFrom(address(msg.sender), address(this), _amount);
    }
    function compound(uint256 _poolId) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Pool storage pool = ds.pools[_poolId];
        TestLib.PoolStaker storage staker = ds.poolStakers[_poolId][msg.sender];
        uint256 rewards = getClaimableRewards(_poolId, msg.sender);
        require(rewards > 0, "Compound amount can't be zero");
        updatePoolRewards(_poolId);

        staker.rewards = 0;
        staker.amount = staker.amount + rewards;
        staker.rewardDebt =
            (staker.amount * pool.accumulatedRewardsPerShare) /
            REWARDS_PRECISION;

        // Update pool
        pool.tokensStaked = pool.tokensStaked + rewards;
    }
    function withdraw(uint256 _poolId) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Pool storage pool = ds.pools[_poolId];
        TestLib.PoolStaker storage staker = ds.poolStakers[_poolId][msg.sender];
        uint256 amount = staker.amount;
        require(amount > 0, "Withdraw amount can't be zero");
        require(
            block.timestamp >= staker.endTime,
            "Lock time is not passed yet!"
        );

        // Pay rewards
        _harvestRewards(_poolId);

        // Update staker
        staker.amount = 0;
        staker.rewardDebt = 0;
        staker.startTime = 0;
        staker.endTime = 0;

        // Update pool
        pool.tokensStaked = pool.tokensStaked - amount;

        // Withdraw tokens
        emit Withdraw(msg.sender, _poolId, amount);
        ds.LNQToken.transfer(address(msg.sender), amount);
    }
    function harvestRewards(uint256 _poolId) external nonReentrant {
        _harvestRewards(_poolId);
    }
    function _harvestRewards(uint256 _poolId) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        updatePoolRewards(_poolId);
        TestLib.Pool storage pool = ds.pools[_poolId];
        TestLib.PoolStaker storage staker = ds.poolStakers[_poolId][msg.sender];
        require(
            block.timestamp >= staker.endTime,
            "Lock time is not passed yet!"
        );
        uint256 rewardsToHarvest = staker.rewards +
            ((staker.amount * pool.accumulatedRewardsPerShare) /
                REWARDS_PRECISION) -
            staker.rewardDebt;
        if (rewardsToHarvest == 0) {
            staker.rewardDebt =
                (staker.amount * pool.accumulatedRewardsPerShare) /
                REWARDS_PRECISION;
            return;
        }
        staker.rewards = 0;
        staker.rewardDebt =
            (staker.amount * pool.accumulatedRewardsPerShare) /
            REWARDS_PRECISION;
        staker.earned += rewardsToHarvest;
        emit HarvestRewards(msg.sender, _poolId, rewardsToHarvest);
        ds.LNQToken.transfer(msg.sender, rewardsToHarvest);
    }
    function updatePoolRewards(uint256 _poolId) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Pool storage pool = ds.pools[_poolId];
        if (pool.tokensStaked == 0) {
            pool.lastRewardedBlock = block.number;
            return;
        }
        uint256 blocksSinceLastReward = block.number - pool.lastRewardedBlock;
        uint256 rewards = blocksSinceLastReward *
            ds.rewardTokensPerBlock[_poolId] *
            1e18;
        pool.accumulatedRewardsPerShare =
            pool.accumulatedRewardsPerShare +
            ((rewards * REWARDS_PRECISION) / pool.tokensStaked);
        pool.lastRewardedBlock = block.number;
    }
    function getClaimableRewards(
        address _user
    ) external view returns (uint256[3] memory) {
        uint256[3] memory claimableRewards;
        for (uint8 i = 0; i < 3; i++) {
            claimableRewards[i] = getClaimableRewards(i, _user);
        }
        return claimableRewards;
    }
}
