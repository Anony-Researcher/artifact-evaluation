// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.heurist.ai/
    Twitter:  https://twitter.com/heurist_ai
    Discord:  https://discord.com/heuristai
    Medium:   https://heuristai.medium.com/

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
