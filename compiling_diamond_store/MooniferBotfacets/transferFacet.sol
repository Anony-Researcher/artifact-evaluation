/**

Moonifer Bot - THE GATEWAY FOR EVERY TRADER TO FIND THE NEXT MOONER ON ETHEREUM
                                         
https://moonifer.bot/
https://twitter.com/mooniferboteth
https://t.me/mooniferbot

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract transferFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function transfer(address recipient, uint256 amount) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount <= ds.balances[msg.sender], "Insufficient balance");
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balances[sender] -= amount;
        ds.balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount <= ds.balances[sender], "Insufficient balance");
        require(
            amount <= ds.allowances[sender][msg.sender],
            "Insufficient allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            ds.allowances[sender][msg.sender] - amount
        );
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}
