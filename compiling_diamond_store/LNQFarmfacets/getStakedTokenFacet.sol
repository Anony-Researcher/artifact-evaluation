//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getStakedTokenFacet {
    function getStakedToken(
        address _user
    ) external view returns (uint256[3] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256[3] memory stakedToken;
        for (uint8 i = 0; i < 3; i++) {
            TestLib.PoolStaker storage staker = ds.poolStakers[i][_user];
            stakedToken[i] = staker.amount;
        }
        return stakedToken;
    }
}
