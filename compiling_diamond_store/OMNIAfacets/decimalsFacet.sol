// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://omniatech.io/
    Twitter:  https://twitter.com/omnia_protocol
    Medium:   https://medium.com/omniaprotocol
    Telegram: https://t.me/Omnia_protocol

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
