// SPDX-License-Identifier: MIT

/** 

Twitter: https://twitter.com/Growminer_
Website: https://www.growminer.com/

**/

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
