//SPDX-License-Identifier: MIT

/*
 https://t.me/DLT_exchange 
 https://twitter.com/dlt_exchange
 https://dltexchange.co
*/

pragma solidity ^0.8.20;

abstract contract Auth {
    address internal _owner;
    event OwnershipTransferred(address _owner);
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this");
        _;
    }
    constructor(address creatorOwner) {
        _owner = creatorOwner;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function transferOwnership(address payable newowner) external onlyOwner {
        _owner = newowner;
        emit OwnershipTransferred(newowner);
    }
    function renounceOwnership() external onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(address(0));
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address holder,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed _owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

string constant _symbol = "DLT";
string constant _name = "Decentralised Leverage Trading";
uint8 constant _decimals = 9;
uint256 constant _totalSupply = 10_000_000 * (10 ** _decimals);
address constant _swapRouterAddress = address(
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
);

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        IUniswapV2Router02 _primarySwapRouter;
        address WETH;
        address LpOwner;
        address _primaryLP;
        mapping(address => bool) _isLP;
        bool _tradingOpen;
        bool _inSwap;
        address payable _marketingWallet;
        uint256 antiMevBlock;
        uint8 _sellTaxrate;
        uint8 _buyTaxrate;
        uint256 launchBlok;
        uint256 _maxTxVal;
        uint256 _maxWalletVal;
        uint256 _swapMin;
        uint256 _swapMax;
        uint256 _swapTrigger;
        uint256 _swapLimits;
        mapping(uint256 => mapping(address => uint8)) blockSells;
        mapping(address => bool) _nofee;
        mapping(address => bool) _nolimit;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
