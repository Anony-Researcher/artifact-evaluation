// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://well3.com/
    Twitter:  https://twitter.com/well3official
    Discord:  https://discord.com/invite/yogapetz

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
