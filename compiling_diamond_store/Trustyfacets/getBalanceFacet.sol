// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract getBalanceFacet {
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
