//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @title Bagpuss
 *
 * @dev memecoin token with additional functionality
 *
 *
 *
 * . .--------------.   .--------------.   .--------------.   .--------------.  .--------------.     .--------------.  .--------------.
 * | |   ______     | | |      __      | | |    ______    | | |   ______     | | | _____  _____ | | |    _______   | | |    _______   | |
 * | |  |_   _ \    | | |     /  \     | | |  .' ___  |   | | |  |_   __ \   | | ||_   _||_   _|| | |   /  ___  |  | | |   /  ___  |  | |
 * | |    | |_) |   | | |    / /\ \    | | | / .'   \_|   | | |    | |__) |  | | |  | |    | |  | | |  |  (__ \_|  | | |  |  (__ \_|  | |
 * | |    |  __'.   | | |   / ____ \   | | | | |    ____  | | |    |  ___/   | | |  | '    ' |  | | |   '.___`-.   | | |   '.___`-.   | |
 * | |   _| |__) |  | | | _/ /    \ \_ | | | \ `.___]  _| | | |   _| |_      | | |   \ `--' /   | | |  |`\____) |  | | |  |`\____) |  | |
 * | |  |_______/   | | ||____|  |____|| | |  `._____.'   | | |  |_____|     | | |    `.__.'    | | |  |_______.'  | | |  |_______.'  | |
 * | |              | | |              | | |              | | |              | | |              | | |              | | |              | |
 * | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' | '--------------' |
 * '----------------' '----------------' '----------------' '----------------' '----------------' '----------------' '----------------'
 *
 *
 *
 *
 * https://www.bagpuss.vip
 *
 * https://www.t.me/bagpussportal
 *
 * https://www.x.com/bagpusstoken
 *
 * Bagpuss is a classical British animated children's television series which was made by Peter Firmin and Oliver Postgate.
 * This most beautiful old cloth cat is now in his 50th year. To celebrate, he decided to take matters into his own paws & create a meme token of himself $Bagpuss, sending a new wave of meow's into the cryptoverse.
 * Hopefully, millions of people like you, will now buy this loveable cat, Bagpuss.
 *
 */

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
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
}

uint8 constant _decimals = 9;
uint256 constant _tTotal = 100000000 * 10 ** _decimals;
string constant _name = unicode"Bagpuss";
string constant _symbol = unicode"BAGP";

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _isExcludedFromFee;
        mapping(address => bool) bots;
        address payable _taxWallet;
        uint256 _initialBuyTax;
        uint256 _initialSellTax;
        uint256 _finalBuyTax;
        uint256 _finalSellTax;
        uint256 _reduceBuyTaxAt;
        uint256 _reduceSellTaxAt;
        uint256 _preventSwapBefore;
        uint256 _buyCount;
        uint256 _maxTxAmount;
        uint256 _maxWalletSize;
        uint256 _taxSwapThreshold;
        uint256 _maxTaxSwap;
        IUniswapV2Router02 uniswapV2Router;
        address uniswapV2Pair;
        bool tradingOpen;
        bool inSwap;
        bool swapEnabled;
        uint256 sellCount;
        uint256 lastSellBlock;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
