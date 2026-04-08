// SPDX-License-Identifier: MIT

/** 

https://www.florkofcows.com/
https://twitter.com/FlockofCows

**/

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
