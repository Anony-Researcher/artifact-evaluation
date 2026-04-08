/*
 * SPDX-License-Identifier: MIT
 * Website: https://eesee.io
 * X: https://twitter.com/eesee_io
 * Tele: https://t.me/eesee_io
 * Discord: https://discord.gg/eesee
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
