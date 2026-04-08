// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://thenextgem.ai/
    Twitter:  https://twitter.com/NextGemAI
    Discord:  https://discord.gg/rpPTF3DRFk
    Telegram: https://t.me/NextGemAI_Group

*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
