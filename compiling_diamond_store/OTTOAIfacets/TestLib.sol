/**
 *Submitted for verification at Etherscan.io on 2022-11-07
 */

//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address _owner,
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
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Auth {
    address internal owner;
    constructor(address _owner) {
        owner = _owner;
    }
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only contract owner can call this function"
        );
        _;
    }
    function transferOwnership(address payable newOwner) external onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(newOwner);
    }
    event OwnershipTransferred(address owner);
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

string constant _name = "OTTOAI";
string constant _symbol = "OTTOAI";
uint8 constant _decimals = 9;
uint256 constant _totalSupply = 1_000_000_000 * 10 ** _decimals;
uint8 constant _maxTaxRate = 5;
address constant _uniswapV2RouterAddress = address(
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
);

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) excludedFromFees;
        bool tradingOpen;
        uint256 taxSwapMin;
        uint256 taxSwapMax;
        mapping(address => bool) _isLiqPool;
        uint8 taxRateBuy;
        uint8 taxRateSell;
        bool antiBotEnabled;
        mapping(address => bool) excludedFromAntiBot;
        mapping(address => uint256) _lastSwapBlock;
        address payable taxWallet;
        bool _inTaxSwap;
        address LPaddress;
        IUniswapV2Router02 _uniswapV2Router;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
