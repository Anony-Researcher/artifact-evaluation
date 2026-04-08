// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract realtimeRewardFacet {
    using SafeMath for uint256;

    modifier onlyowner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "only ds.owner");
        _;
    }

    function realtimeReward(address user) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ret;
        for (uint256 i; i < ds.Stakers[user].stakeCount; i++) {
            if (
                !ds.stakersRecord[user][i].withdrawan &&
                !ds.stakersRecord[user][i].unstaked
            ) {
                uint256 val;
                val = block.timestamp - ds.stakersRecord[user][i].staketime;
                val = val.mul(ds.stakersRecord[user][i].persecondreward);
                if (val < ds.stakersRecord[user][i].reward) {
                    ret += val;
                } else {
                    ret += ds.stakersRecord[user][i].reward;
                }
            }
        }
        return ret;
    }
}
