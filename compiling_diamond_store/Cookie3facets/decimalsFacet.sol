// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://cookie3.co/
    Twitter:  https://twitter.com/cookie3_co
    Medium:   hhttps://medium.com/@cookie3
    Discord:  https://discord.com/invite/cookie3
    Telegram: https://t.me/cookie3_co

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
