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
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
}
