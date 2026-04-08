/**
Official Website: https://blockjoy.com 
Twitter: https://twitter.com/BlockJoyWeb3 
Telegram: https://t.me/BlockJoyAI
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract decimalsFacet is ERC20 {
    function decimals() public view virtual override returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
}
