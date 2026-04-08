// SPDX-License-Identifier: MIT

/** 

https://www.florkofcows.com/
https://twitter.com/FlockofCows

**/

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    function name() public pure returns (string memory) {
        return _name;
    }
}
