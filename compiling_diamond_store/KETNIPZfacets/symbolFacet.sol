// SPDX-License-Identifier: MIT

/** 

A lil bean with a big dream ✨

https://theindifferentduck.com/
https://www.ketnipz.com/

**/

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
