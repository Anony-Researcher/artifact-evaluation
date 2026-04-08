// SPDX-License-Identifier: MIT
/**
 * https://edennetwork.io
 * https://twitter.com/edennetwork
 * https://medium.com/EdenNetwork
 * https://www.linkedin.com/company/edennetwork
 */
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract burnFacet is ERC20, Ownable {
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}
