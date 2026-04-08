// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://nyanheroes.com/
    Twitter:  https://twitter.com/nyanheroes
    Telegram: https://t.me/nyanheroes
    Discord:  https://discord.com/invite/nyanheroes

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
