// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract getOwnerFacet is Ownable {
    using SafeMath for uint256;
    using Address for address payable;

    function getOwner() public view returns (address) {
        return owner();
    }
}
