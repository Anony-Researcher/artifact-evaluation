/*
 * SPDX-License-Identifier: MIT
 * Website: https://burnt.com
 * X: https://twitter.com/burnt_
 * Discord: https://discord.gg/53GSh5Mwxm
 * Telegram: https://t.me/burnt_announcements
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
