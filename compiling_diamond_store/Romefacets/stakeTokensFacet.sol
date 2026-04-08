// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract stakeTokensFacet {
    using SafeMath for uint256;

    function stakeTokens(uint256 _amount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //must be more than 0
        require(_amount > 0, "amount cannot be 0");
        ds.totalStaked = ds.totalStaked + _amount;
        if (ds.totalStaked > ds.totalPool) {
            revert Notstaked({warning: "Warning! Pool limit is reached."});
        }
        if (ds.minstakeAmount > _amount) {
            revert Notstaked({
                warning: "Warning! Your stake amount is lower than minimum stake amount"
            });
        }
        if (ds.maxstakeAmount < _amount) {
            revert Notstaked({
                warning: "Warning! Your stake amount is bigger than maximum stake amount"
            });
        }
        if (ds.poolStatus == false) {
            revert Notstaked({warning: "Warning! Pool status is closed."});
        }
        ds.stakeToken.transferFrom(msg.sender, address(this), _amount);
        ds.stakingBalance[msg.sender] = ds.stakingBalance[msg.sender] + _amount;
        ds.userInfo[msg.sender].push(
            TestLib.UserInfo(block.timestamp, _amount)
        );
        //checking if user staked before or not, if NOT staked adding to array of ds.stakers
        if (!ds.hasStaked[msg.sender]) {
            ds.stakers.push(msg.sender);
        }
    }
}
