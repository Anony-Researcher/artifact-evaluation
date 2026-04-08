pragma solidity 0.8.24;
// SPDX-License-Identifier: MIT

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external;
}

string constant _name = "Liquid Restaking EVM Protocol";
string constant _symbol = "STAKEVM";
uint8 constant _decimals = 18;
uint256 constant _totalSupply = 1000000000 * 10 ** _decimals;
uint256 constant buyInitialFee = 150;
uint256 constant sellInitialFee = 200;
uint8 constant buyTotalFees = 50;
uint8 constant sellTotalFees = 50;
uint8 constant teamFee = 30;
uint8 constant revFee = 35;
uint8 constant marketingFee = 35;
address constant teamWallet = 0xb16BFfA35Fc05fDfC23Aefb66351D42810279Ebe;
address constant revWallet = 0x203CE5C9Ff66E893ca2a98646693844c13eB5562;
address constant marketingWallet = 0x301FC1Af1967A1cA022414843FE0294593aB03e1;
address constant router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
IUniswapV2Router02 constant uniswapV2Router = IUniswapV2Router02(router);
address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct ReduceFeeInfo {
        uint256 swapbuy;
        uint256 swapsell;
        uint256 holdInterval;
    }

    struct TestStorage {
        uint256 maxTransactionAmount;
        uint256 maxWallet;
        uint256 swapTokensAtAmount;
        bool limitsInEffect;
        bool launched;
        uint256 launchBlock;
        uint256 swapLaunchCounter;
        bool swapping;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) isExcludedFromFees;
        mapping(address => bool) isExcludedMaxTransactionAmount;
        mapping(address => bool) automatedMarketMakerPairs;
        uint256 _minReduce;
        mapping(address => undefined) reduceFeeInfo;
        address uniswapV2Pair;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
