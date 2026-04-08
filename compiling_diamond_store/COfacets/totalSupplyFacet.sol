/*
 * SPDX-License-Identifier: MIT
 * Website: https://coordinape.com/?utm_source=icodrops
 * Twitter: https://twitter.com/coordinape
 * Discord: https://discord.gg/DPjmDWEUH5
 */
pragma solidity ^0.8.21;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
