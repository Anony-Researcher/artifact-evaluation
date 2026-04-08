// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://nyanheroes.com/
    Twitter:  https://twitter.com/nyanheroes
    Telegram: https://t.me/nyanheroes
    Discord:  https://discord.com/invite/nyanheroes

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
