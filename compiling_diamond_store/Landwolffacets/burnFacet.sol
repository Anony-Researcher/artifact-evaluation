/**
t.me/LandWolfMeme
*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File @openzeppelin/contracts/utils/Context.sol@v4.4.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract burnFacet is ERC20 {
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
