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
contract nameFacet is Ownable {
    function name() public pure returns (string memory) {
        return _name;
    }
}
