// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TensorChain is IERC20 {
    string public constant name = "TensorChain";
    string public constant symbol = "TChain";
    uint8 public constant decimals = 18; // Standard for Ethereum, allows for detailed transactions

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    uint256 totalSupply_;

    constructor() {
        totalSupply_ = 7000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply_; // Assign all initial tokens to the contract creator
    }


    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address recipient, uint256 numTokens) public override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(numTokens <= balances[msg.sender], "ERC20: transfer amount exceeds balance");
        balances[msg.sender] = balances[msg.sender] - numTokens;
        balances[recipient] = balances[recipient] + numTokens;
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }

    function approve(address spender, uint256 numTokens) public override returns (bool) {
        require(numTokens == 0 || allowed[msg.sender][spender] == 0, "ERC20: non-zero approve requires zero current allowance");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowed[msg.sender][spender] = numTokens;
        emit Approval(msg.sender, spender, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address sender, address recipient, uint256 numTokens) public override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(numTokens <= balances[sender], "ERC20: transfer amount exceeds balance");
        require(numTokens <= allowed[sender][msg.sender], "ERC20: transfer amount exceeds allowance");

        balances[sender] = balances[sender] - numTokens;
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - numTokens;
        balances[recipient] = balances[recipient] + numTokens;
        emit Transfer(sender, recipient, numTokens);
        return true;
    }
}