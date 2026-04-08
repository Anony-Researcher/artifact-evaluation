// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://y8u.ai/
    Twitter:  https://twitter.com/y8udotai
    Telegram: https://t.me/y8udotai

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
