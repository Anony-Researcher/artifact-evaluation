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
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
