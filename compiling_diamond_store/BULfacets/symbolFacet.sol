// SPDX-License-Identifier: MIT

/** 

BUL ON ETHEREUM

**/

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
