// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/*

https://t.me/PugsyMaloneETH

*/

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

interface IFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address lpPair,
        uint
    );
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address lpPair);
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface Initializer {
    function setLaunch(
        address _initialLpPair,
        uint32 _liqAddBlock,
        uint64 _liqAddStamp,
        uint8 dec
    ) external;
    function getConfig() external returns (address, address);
    function getInits(uint256 amount) external returns (uint256, uint256);
    function setLpPair(address pair, bool enabled) external;
    function checkUser(
        address from,
        address to,
        uint256 amt
    ) external returns (bool);
    function setProtections(bool _as, bool _ab) external;
    function removeSniper(address account) external;
    function removeBlacklisted(address account) external;
    function isBlacklisted(address account) external view returns (bool);
    function setBlacklistEnabled(address account, bool enabled) external;
    function setBlacklistEnabledMultiple(
        address[] memory accounts,
        bool enabled
    ) external;
}

uint256 constant startingSupply = 7_770_000_000;
string constant _name = "Raise All-In x Pugsy Poker";
string constant _symbol = "$RAISE";
uint8 constant _decimals = 9;
uint256 constant _tTotal = startingSupply * 10 ** _decimals;
uint256 constant maxBuyTaxes = 3000;
uint256 constant maxSellTaxes = 3000;
uint256 constant maxTransferTaxes = 1000;
uint256 constant masterTaxDivisor = 10000;
address constant DEAD = 0x000000000000000000000000000000000000dEaD;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct Fees {
        uint16 buyFee;
        uint16 sellFee;
        uint16 transferFee;
    }
    struct Ratios {
        uint16 liquidity;
        uint16 marketing;
        uint16 project;
        uint16 operations;
        uint16 totalSwap;
    }
    struct TaxWallets {
        address payable marketing;
        address payable operations;
        address payable project;
    }

    struct TestStorage {
        mapping(address => uint256) _tOwned;
        mapping(address => bool) lpPairs;
        uint256 timeSinceLastPair;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _liquidityHolders;
        mapping(address => bool) _isExcludedFromProtection;
        mapping(address => bool) _isExcludedFromFees;
        mapping(address => bool) _isExcludedFromLimits;
        mapping(address => bool) presaleAddresses;
        bool allowedPresaleExclusion;
        Fees _taxRates;
        Ratios _ratios;
        bool taxesAreLocked;
        IRouter02 dexRouter;
        address lpPair;
        TaxWallets _taxWallets;
        bool inSwap;
        bool contractSwapEnabled;
        uint256 swapThreshold;
        uint256 swapAmount;
        bool piContractSwapsEnabled;
        uint256 piSwapPercent;
        uint256 _maxTxAmount;
        uint256 _maxWalletSize;
        bool tradingEnabled;
        bool _hasLiqBeenAdded;
        Initializer initializer;
        uint256 launchStamp;
        address _owner;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
