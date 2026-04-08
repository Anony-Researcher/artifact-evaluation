/*
 * SPDX-License-Identifier: MIT
 * Website:  https://www.gaimin.io/
 * Telegram: https://t.me/+XFTC523WeTI1MjA0
 * Twitter:  https://twitter.com/GaiminIo
 * Discord:  https://discord.com/invite/jemqJ9PkCJ
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
