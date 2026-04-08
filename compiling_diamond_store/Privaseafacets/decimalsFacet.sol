// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.privasea.ai/
    Twitter:  https://twitter.com/Privasea_ai
    Telegram: https://t.me/Privasea_ai
    Discord:  https://discord.com/invite/yRtQGvWkvG
    Github:   https://github.com/Privasea

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
