//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract checkLockTimeFacet {
    function checkLockTime(
        address _user
    ) external view returns (bool[3] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool[3] memory checkLockState;
        for (uint8 i = 0; i < 3; i++) {
            TestLib.PoolStaker storage staker = ds.poolStakers[i][_user];
            if (staker.endTime == 0) {
                checkLockState[i] = false;
            } else {
                checkLockState[i] = staker.endTime < block.timestamp;
            }
        }
        return checkLockState;
    }
}
