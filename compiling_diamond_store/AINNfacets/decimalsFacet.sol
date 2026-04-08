// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://anvm.io/
    Twitter:  https://twitter.com/AINNLayer2
    Telegram:  https://t.me/AINN_ANVM

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
