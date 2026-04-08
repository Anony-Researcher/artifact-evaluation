/**
    Powered by Wynd Network
    https://www.wyndlabs.ai/

    Wynd Network, blending blockchain technology with AI, focuses on decentralized AI projects. 
    Their main product, Grass, is a decentralized web scraping network that transforms public web data into AI datasets. 
    This process, utilizing millions of home internet connections, is crucial for AI model development across various sectors. 
    Grass serves as a decentralized AI oracle, providing transparent and fairly compensated datasets.
    
    https://app.getgrass.io/
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

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

library SafeERC20 {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: INTERNAL TRANSFER_FAILED"
        );
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
}

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

uint256 constant _totalSupply = 1_000_000_000 * 1e18;
string constant _name = unicode"Grass AI Web Scraping Network";
string constant _symbol = unicode"GRASSAI";
address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant revWallet = 0xd986606beC4A6a4f2cC770561CC5843977758D67;
address constant treasuryWallet = 0xc8692ED7a06d126a84CD1D0DFEDed0AaafE59fc5;
address constant teamWallet = 0x61149097758fEc5544F1aA39dfa46101B61F5A5c; // liquidity wallet
uint256 constant buyInitialFee = 200;
uint256 constant sellInitialFee = 300;
uint8 constant buyTotalFees = 40;
uint8 constant sellTotalFees = 40;
uint8 constant revFee = 50;
uint8 constant treasuryFee = 25;
uint8 constant teamFee = 25;
IUniswapV2Router02 constant uniswapV2Router = IUniswapV2Router02(
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
);

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct ReduceFeeInfo {
        uint256 buy;
        uint256 sell;
        uint256 holdInterval;
    }

    struct TestStorage {
        uint256 maxTransactionAmount;
        uint256 maxWallet;
        uint256 swapTokensAtAmount;
        bool swapping;
        bool limitsInEffect;
        bool launched;
        uint256 launchBlock;
        uint256 buyCount;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _isExcludedFromFees;
        mapping(address => bool) _isExcludedMaxTransactionAmount;
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
