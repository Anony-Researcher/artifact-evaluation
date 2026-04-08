// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract burnFacet is ERC20, Ownable {
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}
