// SPDX-License-Identifier: MIT

/*⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀.⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠛⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 

Drops Lock Marketplace is the first locked liquidity marketplace.
This is the Drops Tier 01 Earning Center smart contract.

https://drops.site
https://t.me/dropserc
https://x.com/dropserc

$DROPS token address -> 0xA562912e1328eEA987E04c2650EfB5703757850C

*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract remainLockTimeFacet {
    using SafeERC20 for IERC20;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewFees(uint256 newDepositFeeBP, uint256 newWithdrawFeeBP);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    function remainLockTime(address _user) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.UserInfo storage user = ds.userInfo[_user];
        uint256 timeElapsed = block.timestamp - (user.depositTime);
        uint256 remainingLockTime = 0;
        if (user.depositTime == 0) {
            remainingLockTime = 0;
        } else if (timeElapsed < ds.contractLockPeriod) {
            remainingLockTime = (ds.contractLockPeriod - (timeElapsed)) >
                ds.bonusEndBlock
                ? ds.bonusEndBlock
                : (ds.contractLockPeriod - (timeElapsed));
        }

        return remainingLockTime;
    }
    function deposit(uint256 _amount) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.UserInfo storage user = ds.userInfo[msg.sender];
        uint256 remainLock = remainLockTime(msg.sender);
        uint256 depositAmount = _amount;
        if (ds.hasUserLimit) {
            require(
                _amount + user.amount <= ds.poolLimitPerUser,
                "User amount above limit"
            );
        }

        _updatePool();
        if (user.amount > 0) {
            uint256 pending = (user.amount * ds.accTokenPerShare) /
                ds.PRECISION_FACTOR -
                user.rewardDebt;
            if (pending > 0 || user.rewardLockedUp > 0) {
                if (remainLock <= 0) {
                    pending = pending + user.rewardLockedUp;
                    ds.rewardToken.safeTransfer(address(msg.sender), pending);
                    user.rewardLockedUp = 0;
                } else if (pending > 0) {
                    user.rewardLockedUp = user.rewardLockedUp + pending;
                }
            }
        }

        if (_amount > 0) {
            require(ds.stakedToken.balanceOf(address(msg.sender)) >= _amount);
            uint256 beforeStakedTokenTotalBalance = ds.stakedToken.balanceOf(
                address(this)
            );
            if (ds.depositFeeBP > 0) {
                uint256 depositFee = (_amount * ds.depositFeeBP) / 10000;
                ds.stakedToken.safeTransferFrom(
                    address(msg.sender),
                    address(this),
                    _amount - depositFee
                );
                ds.stakedToken.safeTransferFrom(
                    address(msg.sender),
                    ds.feeAddress,
                    depositFee
                );
            } else {
                ds.stakedToken.safeTransferFrom(
                    address(msg.sender),
                    address(this),
                    _amount
                );
            }
            uint256 depositedAmount = ds.stakedToken.balanceOf(address(this)) -
                beforeStakedTokenTotalBalance;
            user.amount = user.amount + depositedAmount;
            depositAmount = depositedAmount;
            ds.totalstakedAmount = ds.totalstakedAmount + depositedAmount;
            uint256 shouldNotWithdrawBefore = block.timestamp +
                ds.withdrawalFeeInterval;
            if (shouldNotWithdrawBefore > ds.withdrawalFeeDeadline) {
                shouldNotWithdrawBefore = ds.withdrawalFeeDeadline;
            }
            user.noWithdrawalFeeAfter = shouldNotWithdrawBefore;
            user.depositTime = block.timestamp;
        }

        user.rewardDebt =
            (user.amount * ds.accTokenPerShare) /
            ds.PRECISION_FACTOR;
        emit Deposit(msg.sender, depositAmount);
    }
    function withdraw(uint256 _amount) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.UserInfo storage user = ds.userInfo[msg.sender];
        uint256 remainLock = remainLockTime(msg.sender);
        require(user.amount >= _amount, "Amount to withdraw too high");
        require(remainLock <= 0, "withdraw: locktime remains!");
        _updatePool();

        uint256 pending = (user.amount * ds.accTokenPerShare) /
            ds.PRECISION_FACTOR -
            user.rewardDebt +
            user.rewardLockedUp;

        if (_amount > 0) {
            uint256 beforestakedtokentotalsupply = ds.stakedToken.balanceOf(
                address(this)
            );
            if (ds.withdrawFeeBP > 0) {
                uint256 withdrawFee = (_amount * ds.withdrawFeeBP) / 10000;
                ds.stakedToken.safeTransfer(
                    address(msg.sender),
                    _amount - withdrawFee
                );
                ds.stakedToken.safeTransfer(ds.feeAddress, withdrawFee);
            } else {
                ds.stakedToken.safeTransfer(address(msg.sender), _amount);
            }
            uint256 withdrawamount = beforestakedtokentotalsupply -
                ds.stakedToken.balanceOf(address(this));
            ds.totalstakedAmount = ds.totalstakedAmount - withdrawamount;
            user.amount = user.amount - withdrawamount;
            user.noWithdrawalFeeAfter =
                block.timestamp +
                ds.withdrawalFeeInterval;
        }

        if (pending > 0) {
            ds.rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt =
            (user.amount * ds.accTokenPerShare) /
            ds.PRECISION_FACTOR;
        user.rewardLockedUp = 0;
        emit Withdraw(msg.sender, _amount);
    }
    function emergencyWithdraw() external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.UserInfo storage user = ds.userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;

        if (amountToTransfer > 0) {
            ds.totalstakedAmount = ds.totalstakedAmount - amountToTransfer;
            ds.stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
        }

        emit EmergencyWithdraw(msg.sender, user.amount);
    }
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.rewardToken.safeTransfer(address(msg.sender), _amount);
    }
    function recoverWrongTokens(
        address _tokenAddress,
        uint256 _tokenAmount
    ) external onlyOwner {
        IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }
    function clearStuckBalance(
        uint256 amountPercentage,
        address _walletAddress
    ) external onlyOwner {
        require(_walletAddress != address(this));
        uint256 amountETH = address(this).balance;
        payable(_walletAddress).transfer((amountETH * amountPercentage) / 100);
    }
    function stopReward() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bonusEndBlock = block.number;
    }
    function updatePoolLimitPerUser(
        bool _hasUserLimit,
        uint256 _poolLimitPerUser
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.hasUserLimit, "Must be set");
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > ds.poolLimitPerUser,
                "New limit must be higher"
            );
            ds.poolLimitPerUser = _poolLimitPerUser;
        } else {
            ds.hasUserLimit = _hasUserLimit;
            ds.poolLimitPerUser = 0;
        }
        emit NewPoolLimit(ds.poolLimitPerUser);
    }
    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }
    function updateFees(
        uint256 _newDepositFeeBP,
        uint256 _newWithdrawFeeBP
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newDepositFeeBP <= 10000, "Cannot be bigger than 100");
        require(_newWithdrawFeeBP <= 10000, "Cannot be bigger than 100");
        ds.depositFeeBP = _newDepositFeeBP;
        ds.withdrawFeeBP = _newWithdrawFeeBP;
        emit NewFees(ds.depositFeeBP, ds.withdrawFeeBP);
    }
    function updateStartAndEndBlocks(
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _withdrawalFeeInterval,
        uint256 _withdrawalFeeDeadline,
        uint256 _contractLockPeriod
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _startBlock < _bonusEndBlock,
            "New ds.startBlock must be lower than new endBlock"
        );
        require(
            block.number < _startBlock,
            "New ds.startBlock must be higher than current block"
        );

        ds.startBlock = _startBlock;
        ds.bonusEndBlock = _bonusEndBlock;
        ds.withdrawalFeeInterval = _withdrawalFeeInterval;
        ds.withdrawalFeeDeadline = _withdrawalFeeDeadline;
        ds.contractLockPeriod = _contractLockPeriod;

        // Set the ds.lastRewardBlock as the ds.startBlock
        ds.lastRewardBlock = ds.startBlock;

        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
    }
    function calcRewardPerBlock() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(block.number < ds.startBlock, "Pool has started");
        uint256 rewardBal = ds.rewardToken.balanceOf(address(this));
        ds.rewardPerBlock = rewardBal / rewardDuration();
    }
    function rewardDuration() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bonusEndBlock - ds.startBlock;
    }
    function _updatePool() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (block.number <= ds.lastRewardBlock) {
            return;
        }

        if (ds.totalstakedAmount == 0) {
            ds.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(ds.lastRewardBlock, block.number);
        uint256 vivReward = multiplier * ds.rewardPerBlock;
        ds.accTokenPerShare =
            ds.accTokenPerShare +
            ((vivReward * ds.PRECISION_FACTOR) / ds.totalstakedAmount);
        ds.lastRewardBlock = block.number;
    }
    function _getMultiplier(
        uint256 _from,
        uint256 _to
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_to <= ds.bonusEndBlock) {
            return _to - _from;
        } else if (_from >= ds.bonusEndBlock) {
            return 0;
        } else {
            return ds.bonusEndBlock - _from;
        }
    }
    function pendingReward(address _user) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.UserInfo storage user = ds.userInfo[_user];
        if (block.number > ds.lastRewardBlock && ds.totalstakedAmount != 0) {
            uint256 multiplier = _getMultiplier(
                ds.lastRewardBlock,
                block.number
            );
            uint256 vivReward = multiplier * ds.rewardPerBlock;
            uint256 adjustedTokenPerShare = ds.accTokenPerShare +
                ((vivReward * ds.PRECISION_FACTOR) / ds.totalstakedAmount);
            return
                (user.amount * adjustedTokenPerShare) /
                ds.PRECISION_FACTOR -
                user.rewardDebt;
        } else {
            return
                (user.amount * ds.accTokenPerShare) /
                ds.PRECISION_FACTOR -
                user.rewardDebt;
        }
    }
}
