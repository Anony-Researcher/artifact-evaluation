// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://alienxchain.io/
    Twitter:  https://twitter.com/ALIENXchain
    Discord:  https://discord.com/kDcfe3mH
    Telegram: https://t.me/alienx_ainode
    Medium:   https://medium.com/@ALIENXchain

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
