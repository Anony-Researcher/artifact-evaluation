// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _calculateRewardsFacet {
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

    event Staked(address indexed user, uint256 amount);
    event WithdrawRequested(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    function _calculateRewards(address account) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 shares = ds.userStakes[account].stakedAmount;
        return
            (shares * (ds.rewardIndex - ds.rewardIndexOf[account])) /
            MULTIPLIER;
    }
    function calculateRewardsEarned(
        address account
    ) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.userStakes[account].rewards + _calculateRewards(account);
    }
    function _updateRewards(address account) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rewards = _calculateRewards(account);
        uint256 fee = (rewards * ds.managementFee) / 10_000;

        ds.userStakes[account].rewards += (rewards - fee);
        ds.userStakes[ds.marketingWallet].rewards += fee;

        ds.rewardIndexOf[account] = ds.rewardIndex;
    }
    function depositAndStake(uint256 _amount) external whenStakeNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_amount >= ds.MIN_STAKE_AMOUNT, "Not enough staking amount");

        // Update rewards
        _updateRewards(msg.sender);

        // Transfer TRB to this contract
        ds.tellorFlex.transferFrom(msg.sender, address(this), _amount);

        // Update stake data
        TestLib.Stake storage _stake = ds.userStakes[msg.sender];
        _stake.stakedAmount += _amount;

        // Increase total staked amount
        ds.totalStakedAmount += _amount;

        // stake into Tellor Oracle contract
        ds.tellorFlex.approve(address(ds.tellorOracle), _amount);
        ds.tellorOracle.depositStake(_amount);

        emit Staked(msg.sender, _amount);
    }
    function approve(address _spender, uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tellorFlex.approve(_spender, _amount);
    }
    function requestStakingWithdraw(uint256 _amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Stake storage _stake = ds.userStakes[msg.sender];
        require(_stake.stakedAmount >= _amount, "Insufficient staked amount");

        // Update rewards
        _updateRewards(msg.sender);

        // Update locked data
        _stake.lockedAmount += _amount;
        _stake.lockedTimestamp = block.timestamp;
        _stake.stakedAmount -= _amount;

        ds.totalStakedAmount -= _amount;

        // Request staking to tellor oracle contract
        ds.tellorOracle.requestStakingWithdraw(_amount);

        emit WithdrawRequested(msg.sender, _amount);
    }
    function claimRewards() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _updateRewards(msg.sender);

        TestLib.Stake storage _stake = ds.userStakes[msg.sender];

        uint256 balance = ds.tellorFlex.balanceOf(address(this));
        ds.tellorFlex.transfer(
            msg.sender,
            balance > _stake.rewards ? _stake.rewards : balance
        );

        emit RewardClaimed(msg.sender, _stake.rewards);

        _stake.rewards = 0;
    }
}
