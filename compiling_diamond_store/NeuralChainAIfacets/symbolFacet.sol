//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
