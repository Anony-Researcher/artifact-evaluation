/*
 * SPDX-License-Identifier: MIT
 * Website: https://well3.com/
 * X: https://twitter.com/well3official
 * Discord: https://discord.gg/yogapetz
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
