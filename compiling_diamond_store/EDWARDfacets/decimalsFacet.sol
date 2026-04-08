/**

Edward Paperhands - HODL

Links below:

https://edwardpaperhands.lol/

https://twitter.com/Edward_Paperhan

https://t.me/edwardpaperhandsportal

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
