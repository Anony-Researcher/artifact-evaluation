//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    function name() public pure returns (string memory) {
        return _name;
    }
}
