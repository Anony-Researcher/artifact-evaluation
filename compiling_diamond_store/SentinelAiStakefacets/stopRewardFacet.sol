//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract stopRewardFacet is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    function stopReward() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        updatePool(0);
        ds.apy = 0;
    }
    function startReward() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.poolInfo[0].lastRewardTimestamp == 21799615,
            "Can only start rewards once"
        );
        ds.poolInfo[0].lastRewardTimestamp = block.timestamp;
    }
    function massUpdatePools() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 length = ds.poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    function deposit(uint256 _amount) public nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.holderUnlockTime[msg.sender] == 0) {
            ds.holderUnlockTime[msg.sender] = block.timestamp + ds.lockDuration;
        }
        TestLib.PoolInfo storage pool = ds.poolInfo[0];
        TestLib.UserInfo storage user = ds.userInfo[msg.sender];

        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accTokensPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            if (pending > 0) {
                require(
                    pending <= rewardsRemaining(),
                    "Cannot withdraw other people's staked tokens.  Contact an admin."
                );
                ds.rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }
        uint256 amountTransferred = 0;
        if (_amount > 0) {
            uint256 initialBalance = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            amountTransferred =
                pool.lpToken.balanceOf(address(this)) -
                initialBalance;
            user.amount = user.amount.add(amountTransferred);
            ds.totalStaked += amountTransferred;
        }
        user.rewardDebt = user.amount.mul(pool.accTokensPerShare).div(1e12);

        emit Deposit(msg.sender, _amount);
    }
    function withdraw() public nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.holderUnlockTime[msg.sender] <= block.timestamp,
            "May not do normal withdraw early"
        );

        TestLib.PoolInfo storage pool = ds.poolInfo[0];
        TestLib.UserInfo storage user = ds.userInfo[msg.sender];

        uint256 _amount = user.amount;
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accTokensPerShare).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            require(
                pending <= rewardsRemaining(),
                "Cannot withdraw other people's staked tokens.  Contact an admin."
            );
            ds.rewardToken.safeTransfer(address(msg.sender), pending);
        }

        if (_amount > 0) {
            user.amount = 0;
            ds.totalStaked -= _amount;
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        user.rewardDebt = user.amount.mul(pool.accTokensPerShare).div(1e12);

        if (user.amount > 0) {
            ds.holderUnlockTime[msg.sender] = block.timestamp + ds.lockDuration;
        } else {
            ds.holderUnlockTime[msg.sender] = 0;
        }

        emit Withdraw(msg.sender, _amount);
    }
    function emergencyWithdraw() external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.PoolInfo storage pool = ds.poolInfo[0];
        TestLib.UserInfo storage user = ds.userInfo[msg.sender];
        uint256 _amount = user.amount;
        ds.totalStaked -= _amount;
        // exit penalty for early unstakers, penalty held on contract as rewards.
        if (ds.holderUnlockTime[msg.sender] >= block.timestamp) {
            _amount -= (_amount * ds.exitPenaltyPerc) / 100;
        }
        ds.holderUnlockTime[msg.sender] = 0;
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        user.amount = 0;
        user.rewardDebt = 0;
        emit EmergencyWithdraw(msg.sender, _amount);
    }
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _amount <= ds.rewardToken.balanceOf(address(this)) - ds.totalStaked,
            "not enough tokens to take out"
        );
        ds.rewardToken.safeTransfer(address(msg.sender), _amount);
    }
    function updateApy(uint256 newApy) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newApy <= 10000, "APY must be below 10000%");
        updatePool(0);
        ds.apy = newApy;
    }
    function updatelockduration(uint256 newlockDuration) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newlockDuration <= 2419200, "Duration must be below 2 weeks");
        ds.lockDuration = newlockDuration;
    }
    function updateExitPenalty(uint256 newPenaltyPerc) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newPenaltyPerc <= 20, "May not set higher than 20%");
        ds.exitPenaltyPerc = newPenaltyPerc;
    }
    function updatePool(uint256 _pid) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.PoolInfo storage pool = ds.poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTimestamp) {
            return;
        }
        uint256 lpSupply = ds.totalStaked;
        if (lpSupply == 0) {
            pool.lastRewardTimestamp = block.timestamp;
            return;
        }
        uint256 tokenReward = calculateNewRewards().mul(pool.allocPoint).div(
            ds.totalAllocPoint
        );
        pool.accTokensPerShare = pool.accTokensPerShare.add(
            tokenReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardTimestamp = block.timestamp;
    }
    function calculateNewRewards() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.PoolInfo storage pool = ds.poolInfo[0];
        if (pool.lastRewardTimestamp > block.timestamp) {
            return 0;
        }
        return ((((block.timestamp - pool.lastRewardTimestamp) *
            ds.totalStaked) * ds.apy) /
            100 /
            365 days);
    }
    function pendingReward(address _user) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.PoolInfo storage pool = ds.poolInfo[0];
        TestLib.UserInfo storage user = ds.userInfo[_user];
        if (pool.lastRewardTimestamp == 21799615) {
            return 0;
        }
        uint256 accTokensPerShare = pool.accTokensPerShare;
        uint256 lpSupply = ds.totalStaked;
        if (block.timestamp > pool.lastRewardTimestamp && lpSupply != 0) {
            uint256 tokenReward = calculateNewRewards()
                .mul(pool.allocPoint)
                .div(ds.totalAllocPoint);
            accTokensPerShare = accTokensPerShare.add(
                tokenReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accTokensPerShare).div(1e12).sub(user.rewardDebt);
    }
    function rewardsRemaining() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.rewardToken.balanceOf(address(this)) - ds.totalStaked;
    }
}
