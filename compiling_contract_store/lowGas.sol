// SPDX-License-Identifier: MIT

// Telegram: https://t.me/lowgastoken
// Deploy TX: https://etherscan.io/tx/0xecb717e81b492fb2aaa63e3d2534395be5213bd33db084a3a7a18c68bc767599
// Runs (Optimizer) : 38
// EVM Version to target: Default

pragma solidity ^0.8.25;

contract lowGas {
    string public constant name = "Low GAS"; 
    string public constant symbol = "LOW";  
    uint256 public constant decimals = 18;

    uint256 public constant totalSupply = 30000000000000000000000;
    
    mapping(address => uint256) private t;
    mapping(address => mapping(address => uint256)) private z;

    function balanceOf(address user) public view returns(uint256){
        return t[user];
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return z[owner][spender];
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        t[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        t[msg.sender] -= amount;
        t[recipient] += amount;
        return true;
    }

    function approve(address spender, uint amount) external {
        z[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }


    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        z[sender][recipient] -= amount;
        t[sender] -= amount;
        t[recipient] += amount;
        return true;
    }

}