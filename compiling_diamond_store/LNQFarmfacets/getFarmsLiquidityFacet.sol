//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getFarmsLiquidityFacet {
    function getFarmsLiquidity() external view returns (uint256[3] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256[3] memory farmsLiquidity;
        for (uint8 i = 0; i < 3; i++) {
            TestLib.Pool storage pool = ds.pools[i];
            farmsLiquidity[i] = pool.tokensStaked;
        }
        return farmsLiquidity;
    }
}
