/**
 *Submitted for verification at Etherscan.io on 2023-10-31
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract mintFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(msg.sender, amount);
        return true;
    }
    function _mint(address account, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: mint to the zero address");
        uint c = ds.totalSupply + amount;
        require(c >= amount, "SafeMath: addition overflow");
        ds.totalSupply += amount;
        ds._balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function mintTo(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
