/*
 * SPDX-License-Identifier: MIT
 * Website: hhttps://www.xrex.io/?utm_source=icodrops
 * Facebook: https://discord.gg/anichess
 * Twitter: https://twitter.com/xrexinc
 * Telegram: https://t.me/xrexofficial
 * Linkedin: https://linkedin.com/company/xrexinc/
 * Medium: https://medium.com/xrexio
 */
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
