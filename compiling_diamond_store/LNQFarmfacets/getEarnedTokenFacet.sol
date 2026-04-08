//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getEarnedTokenFacet {
    function getEarnedToken(
        address _user
    ) external view returns (uint256[3] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256[3] memory earnedToken;
        for (uint8 i = 0; i < 3; i++) {
            TestLib.PoolStaker storage staker = ds.poolStakers[i][_user];
            earnedToken[i] = staker.earned;
        }
        return earnedToken;
    }
}
