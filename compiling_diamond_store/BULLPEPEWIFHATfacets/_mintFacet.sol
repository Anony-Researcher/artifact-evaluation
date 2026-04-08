/**
 *Submitted for verification at Etherscan.io on 2023-09-17
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./TestLib.sol";
contract _mintFacet {
    function _mint(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: mint to the zero address");

        ds._totalSupply += amount;
        ds._balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}
