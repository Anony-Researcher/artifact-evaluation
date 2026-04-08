/**
 *Submitted for verification at Etherscan.io on 2023-10-31
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract transferFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            ds._balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        ds._balances[sender] -= amount;
        uint c = ds._balances[recipient] + amount;
        require(c >= amount, "SafeMath: addition overflow");
        ds._balances[recipient] = c;
        emit Transfer(sender, recipient, amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        require(
            ds._allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(
            sender,
            msg.sender,
            ds._allowances[sender][msg.sender] - amount
        );
        return true;
    }
    function _approve(
        address account,
        address spender,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[account][spender] = amount;
        emit Approval(account, spender, amount);
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint c = ds._allowances[msg.sender][spender] + addedValue;
        require(c >= addedValue, "SafeMath: addition overflow");
        _approve(msg.sender, spender, c);
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._allowances[msg.sender][msg.sender] >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(
            msg.sender,
            spender,
            ds._allowances[msg.sender][msg.sender] - subtractedValue
        );
        return true;
    }
}
