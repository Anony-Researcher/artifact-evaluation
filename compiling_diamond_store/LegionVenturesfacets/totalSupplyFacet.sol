/*
 * SPDX-License-Identifier: MIT
 * Telegram: https://t.me/LegionVentures
 * Twitter: https://twitter.com/Legion_Ventures
 * Discord: https://discord.com/invite/legion-ventures
 * Website: https://legion.ventures/
 */
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
