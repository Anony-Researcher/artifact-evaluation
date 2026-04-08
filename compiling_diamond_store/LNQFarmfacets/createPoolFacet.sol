//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract createPoolFacet {
    event PoolCreated(uint256 poolId);
    function createPool() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Pool memory pool;
        ds.pools.push(pool);
        uint256 poolId = ds.pools.length - 1;
        emit PoolCreated(poolId);
    }
}
