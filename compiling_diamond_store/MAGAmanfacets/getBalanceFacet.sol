// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getBalanceFacet is ERC20 {
    function getBalance() private view returns (uint256) {
        return address(this).balance;
    }
}
