// SPDX-License-Identifier: MIT
/*
SPICE AI

Building blocks for data and time-series AI applications
Composable, ready-to-use data and AI infrastructure pre-loaded with web3 data. 
Accelerate development of the next generation of intelligent software.

Github: https://github.com/spiceai/spiceai
*/

pragma solidity 0.8.24;

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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

string constant _name = "Spice AI";
string constant _symbol = "SAI";
uint256 constant _totalSupply = 1000000000 * 1e18;
address constant teamWallet = 0xa04F5b2DD5c158BB1A67A89E096A15d822140106;
address constant revWallet = 0x04E6f208d801A52DF12442B29fe707F9804d933d;
address constant marketingWallet = 0x6b834C151a8c05Eeb512228e71cA5e663430921C;
uint256 constant buyInitialFee = 200;
uint256 constant sellInitialFee = 300;
uint8 constant buyTotalFees = 50;
uint8 constant sellTotalFees = 50;
uint8 constant teamFee = 20;
uint8 constant revFee = 40;
uint8 constant marketingFee = 40;
IUniswapV2Router02 constant uniswapV2Router = IUniswapV2Router02(
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
);
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
        bool swapping;
        bool limitsInEffect;
        bool launched;
        uint256 launchBlock;
        uint256 buyCount;
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
