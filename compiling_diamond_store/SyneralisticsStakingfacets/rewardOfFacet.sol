// SPDX-License-Identifier: MIT

/** 
SYNERALISTICS emerges as a pioneering layer 1 blockchain project dedicated to bridging the gap between traditional assets and decentralized finance (DeFi) 
through innovative blockchain technology. By leveraging the capabilities of layer 1 blockchain, SYNERALISTICS aims to revolutionize the management and utilization 
of real-world assets on the blockchain, paving the way for enhanced liquidity, transparency, and accessibility.
       Website: https://syneralistics.io/
       Telegram: https://t.me/syneralistics
       Medium: https://medium.com/@syneralisticsofficial
       Twitter: https://x.com/syneralistics
       Github: https://github.com/Syneralistics
**/

pragma solidity ^0.8;
import "./TestLib.sol";
contract rewardOfFacet is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event RewardSent(address _address, uint256 _amount, uint256 _timestamp);
    function rewardOf(address _stakeholder) public view returns (uint256) {
        (uint256 reward, ) = calculateReward(_stakeholder);
        return reward;
    }
    function calculateReward(
        address _stakeholder
    ) private view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 stakedAmount = ds.stakes[_stakeholder];
        if (stakedAmount == 0) {
            return (0, 0);
        }
        uint256 _stakingTimestamp = ds.stakingTimestamp[_stakeholder];
        if (_stakingTimestamp == 0) {
            return (0, 0);
        }
        uint256 _currentTimestamp = block.timestamp;
        uint256 _span = _currentTimestamp.sub(_stakingTimestamp);
        uint256 _stakingPackage = ds.stakingPackage[_stakeholder];
        if (_span < _stakingPackage) {
            return (0, 0);
        }
        uint256 _loops = _span / _stakingPackage;
        uint256 rewardPercentage = ds.packages[_stakingPackage];
        uint256 _reward = stakedAmount.mul(rewardPercentage).mul(_loops).div(
            100
        );
        return (_reward, _loops);
    }
    function _withdrawReward(address _stakeholder) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint256 reward, uint256 loops) = calculateReward(_stakeholder);
        if (reward == 0) {
            return;
        }
        uint256 myPackage = ds.stakingPackage[_stakeholder];

        ds.stakingTimestamp[_stakeholder] = (ds.stakingTimestamp[_stakeholder])
            .add(myPackage * loops);

        ds.token.transfer(msg.sender, reward);
        ds.totalRewardDistributed += reward;
        emit RewardSent(_stakeholder, reward, block.timestamp);
    }
    function distributeReward() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.stakeholders.length == 0) {
            return;
        }
        if (ds.rewardDistributionIndex == ds.stakeholders.length - 1) {
            ds.rewardDistributionIndex = 0;
        }

        for (
            uint256 i = ds.rewardDistributionIndex;
            i < ds.stakeholders.length;
            i++
        ) {
            address account = ds.stakeholders[i];
            (uint256 reward, ) = calculateReward(account);
            ds.rewardDistributionIndex = i;
            if (reward == 0) {
                continue;
            } else {
                _withdrawReward(account);
                break;
            }
        }
    }
    function claimReward() public {
        (uint256 reward, ) = calculateReward(msg.sender);
        if (reward > 0) {
            _withdrawReward(msg.sender);
        }
    }
}
