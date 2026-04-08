/**
 *Submitted for verification at Etherscan.io on 2023-09-17
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./TestLib.sol";
contract _burnFacet is Context {
    function _burn(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = ds._balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            ds._balances[account] = accountBalance - amount;
        }
        ds._totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }
    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}
