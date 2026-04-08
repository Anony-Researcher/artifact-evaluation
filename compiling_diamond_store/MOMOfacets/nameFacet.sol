// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.momoai.io/
    Twitter:  https://twitter.com/Metaoasis_
    Telegram: https://t.me/metaoasis
    Discord:  https://discord.com/invite/momoai

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
