//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getAPRForUserFacet {
    function getAPRForUser(
        address _user
    ) external view returns (uint256[3] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256[3] memory APR;
        for (uint8 i = 0; i < 3; i++) {
            TestLib.Pool storage pool = ds.pools[i];
            TestLib.PoolStaker storage staker = ds.poolStakers[i][_user];
            if (pool.tokensStaked > 0) {
                APR[i] = (staker.amount * 100000) / pool.tokensStaked;
            } else {
                APR[i] = 0;
            }
        }
        return APR;
    }
}
