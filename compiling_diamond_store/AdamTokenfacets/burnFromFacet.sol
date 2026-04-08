// SPDX-License-Identifier: MIT
/**
 * https://edennetwork.io
 * https://twitter.com/edennetwork
 * https://medium.com/EdenNetwork
 * https://www.linkedin.com/company/edennetwork
 */
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract burnFromFacet is ERC20, Ownable {
    function burnFrom(address account, uint256 amount) external {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}
