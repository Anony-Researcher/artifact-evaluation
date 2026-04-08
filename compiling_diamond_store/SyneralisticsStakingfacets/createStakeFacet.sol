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
contract createStakeFacet is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function createStake(uint256 _stake, uint256 _stakingPackage) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _stakingPackage = 0;
        bool _canStake = canStake(_stake, _stakingPackage, msg.sender);
        require(_canStake, "Cannot Stake");
        ds.token.transferFrom(msg.sender, address(this), _stake);
        _stakingPackage = _stakingPackage * ds.uintTime;
        addStakeholder(msg.sender, _stake, _stakingPackage);
        ds._totalStakes = ds._totalStakes.add(_stake);
    }
    function canStake(
        uint256 _stake,
        uint256 _stakingPackage,
        address account
    ) public view returns (bool b) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds.packages[_stakingPackage] >= 0 &&
            _stake <= ds.token.balanceOf(account) &&
            ds.stakes[account] == 0 &&
            _stake > 0
        ) {
            return true;
        } else {
            return false;
        }
    }
    function addStakeholder(
        address _stakeholder,
        uint256 _stake,
        uint256 _package
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);

        if (!_isStakeholder) {
            ds.stakeholders.push(_stakeholder);
        }

        ds.stakingTimestamp[_stakeholder] = block.timestamp;
        ds.stakingPackage[_stakeholder] = _package;
        ds.stakes[_stakeholder] = _stake;
    }
    function isStakeholder(
        address _address
    ) public view returns (bool, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 s = 0; s < ds.stakeholders.length; s++) {
            if (_address == ds.stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }
    function removeStakeholder(address _stakeholder) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            ds.stakeholders[s] = ds.stakeholders[ds.stakeholders.length - 1];
            ds.stakeholders.pop();
            ds.stakingTimestamp[_stakeholder] = 0;
            ds.stakingPackage[_stakeholder] = 0;
        }
    }
    function removeSomeStake(uint256 _stake) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_stake <= ds.stakes[msg.sender], "Exceeding stake amount");

        ds.stakes[msg.sender] = ds.stakes[msg.sender].sub(_stake);
        if (ds.stakes[msg.sender] == 0) {
            removeStakeholder(msg.sender);
        }

        uint256 period = ds.stakingPackage[msg.sender];
        uint256 stakinTimestamp = ds.stakingTimestamp[msg.sender];

        ds._totalStakes = ds._totalStakes.sub(_stake);

        if ((stakinTimestamp + period) > block.timestamp) {
            uint256 unstakingFee = _stake.mul(10).div(100);
            _stake = _stake.sub(unstakingFee);
        }
        ds.token.transfer(msg.sender, _stake);
    }
    function removeAllMyStakes() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amount = ds.stakes[msg.sender];
        removeSomeStake(amount);
    }
}
