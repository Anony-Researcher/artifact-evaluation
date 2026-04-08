// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.mode.network/
    Twitter:  https://twitter.com/modenetwork
    Telegram: https://t.me/ModeNetworkOfficial
    Docs:   https://docs.mode.network/
    Discord:  https://discord.com/invite/modenetworkofficial

*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokensymbol;
    }
}
