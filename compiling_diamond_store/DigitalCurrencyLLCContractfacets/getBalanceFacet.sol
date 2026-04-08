// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract getBalanceFacet {
    using SafeERC20 for IERC20;

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
