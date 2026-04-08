/**
https://ponzitokenerc.com
/*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract burnFacet is ERC20 {
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
