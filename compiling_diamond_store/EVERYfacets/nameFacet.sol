// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.everyworld.com/
    Twitter:  https://twitter.com/joineveryworld
    Youtube:  https://www.youtube.com/@JoinEveryworld
    Telegram: https://t.me/joineveryworld
    Discord:  http://discord.gg/everyworld

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
