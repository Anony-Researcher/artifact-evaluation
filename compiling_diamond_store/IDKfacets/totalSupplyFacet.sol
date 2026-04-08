// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20 {
    function totalSupply() public view returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view returns (uint balance) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balances[account];
    }
    function transfer(
        address recipient,
        uint amount
    ) public returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balances[msg.sender] = ds.balances[msg.sender] - amount;
        ds.balances[recipient] = ds.balances[recipient] + amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(
        address spender,
        uint amount
    ) public returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balances[sender] = ds.balances[sender] - amount;
        ds.allowed[sender][msg.sender] =
            ds.allowed[sender][msg.sender] -
            amount;
        ds.balances[recipient] = ds.balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view returns (uint remaining) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.allowed[owner][spender];
    }
}
