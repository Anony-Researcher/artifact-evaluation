// SPDX-License-Identifier: MIT

/** 

I’m a duck. An indifferent duck.

https://theindifferentduck.com/
https://twitter.com/IndifferentDuck

**/

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    function name() public pure returns (string memory) {
        return _name;
    }
}
