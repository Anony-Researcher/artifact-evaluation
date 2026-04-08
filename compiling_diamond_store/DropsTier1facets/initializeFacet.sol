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
contract initializeFacet {
    using SafeERC20 for IERC20;

    function initialize(
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _poolLimitPerUser,
        uint256 _depositFeeBP,
        uint256 _withdrawFeeBP,
        uint256 _withdrawalFeeInterval,
        uint256 _withdrawalFeeDeadline,
        uint256 _contractLockPeriod
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isInitialized, "Already initialized");
        require(msg.sender == ds.SMART_CHEF_FACTORY, "Not factory");
        require(_depositFeeBP <= 10000, "Cannot be bigger than 100");
        require(_withdrawFeeBP <= 10000, "Cannot be bigger than 100");

        ds.isInitialized = true;

        ds.stakedToken = _stakedToken;
        ds.rewardToken = _rewardToken;
        ds.rewardPerBlock = _rewardPerBlock;
        ds.startBlock = _startBlock;
        ds.bonusEndBlock = _bonusEndBlock;
        ds.depositFeeBP = _depositFeeBP;
        ds.withdrawFeeBP = _withdrawFeeBP;
        ds.withdrawalFeeInterval = _withdrawalFeeInterval;
        ds.withdrawalFeeDeadline = _withdrawalFeeDeadline;
        ds.contractLockPeriod = _contractLockPeriod;
        if (_poolLimitPerUser > 0) {
            ds.hasUserLimit = true;
            ds.poolLimitPerUser = _poolLimitPerUser;
        }

        uint256 decimalsRewardToken = IERC20(_rewardToken).decimals();
        require(decimalsRewardToken < 30, "Must be inferior to 30");

        ds.PRECISION_FACTOR = uint256(10 ** (30 - decimalsRewardToken));

        // Set the ds.lastRewardBlock as the ds.startBlock
        ds.lastRewardBlock = ds.startBlock;
    }
}
