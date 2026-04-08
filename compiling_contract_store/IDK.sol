// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint balance);
    function transfer(address recipient, uint amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint remaining);
    function approve(address spender, uint amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
} 

//Actual Token Contract
contract IDK is IERC20 {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances; 
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        symbol = "IDK";
        name = "This Will Probably Rug But IDK"; 
        decimals = 18;
        _totalSupply = 1_000_000_000_000_000_000_000_000_000;
        balances[0xE72B91b1B88f55BEbacc5E2D5fe40CE426A75a4E] = _totalSupply;
        emit Transfer(address(0), 0xE72B91b1B88f55BEbacc5E2D5fe40CE426A75a4E, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint balance) {
        return balances[account];
    }

    function transfer(address recipient, uint amount) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
        function approve(address spender, uint amount) public returns (bool success) {
            allowed[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }

        function transferFrom(address sender, address recipient, uint amount) public returns (bool success) {
            balances[sender] = balances[sender] - amount;
            allowed[sender][msg.sender] = allowed[sender][msg.sender] - amount;
            balances[recipient] = balances[recipient] + amount;
            emit Transfer(sender, recipient, amount);
            return true;
        }

        function allowance(address owner, address spender) public view returns (uint remaining) {
            return allowed[owner][spender];
        }
}