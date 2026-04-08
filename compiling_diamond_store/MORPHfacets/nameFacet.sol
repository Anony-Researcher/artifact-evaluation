// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.morphl2.io/
    Twitter:  https://twitter.com/Morphl2
    Gitbook:  https://docs.morphl2.io/
    Telegram: https://t.me/MorphL2official
    Discord:  https://discord.gg/5SmG4yhzVZ

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
