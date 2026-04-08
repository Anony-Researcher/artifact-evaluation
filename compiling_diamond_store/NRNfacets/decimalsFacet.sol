// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.aiarena.io/
    Twitter:  https://twitter.com/aiarena_
    Discord:  https://discord.gg/aiarena
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
