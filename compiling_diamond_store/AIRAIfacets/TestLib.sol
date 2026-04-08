// SPDX-License-Identifier: MIT
/*

Airstack AI Blockchain Developer Tool

The most straightforward method for constructing modular blockchain applications.
Seamlessly incorporate both on-chain and off-chain data into any software instantly using AI.

https://www.airstack.xyz/
https://docs.airstack.xyz/airstack-docs-and-faqs
https://twitter.com/airstack_xyz
https://www.linkedin.com/company/airstack-xyz
https://app.airstack.xyz/sdks
https://warpcast.com/~/channel/airstack
https://app.airstack.xyz/api-studio

*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

uint256 constant _initBuyTax = 15;
uint256 constant _initSellTax = 25;
uint256 constant _finalBuyTax = 5;
uint256 constant _finalSellTax = 5;
uint256 constant _reduceBuyTaxAt = 1;
uint256 constant _reduceSellTaxAt = 25;
uint256 constant _preventSwapBefore = 10;
uint8 constant _decimals = 9;
string constant _name = unicode"Airstack AI";
string constant _symbol = unicode"AIRAI";
uint256 constant _tTotal = 100000000 * 10 ** _decimals;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct LockData {
        uint256 buy;
        uint256 sell;
        uint256 lockPoints;
    }

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _isFeeExempt;
        uint256 maxTxAmount;
        uint256 maxWallet;
        uint256 _taxSwapThreshold;
        uint256 _maxTaxSwap;
        IUniswapV2Router02 router;
        address _pair;
        address payable _taxWallet;
        address payable _projectWallet;
        bool transferDelayEnabled;
        mapping(address => uint256) _holderLastTransferTimestamp;
        uint256 _buyCounter;
        bool _tradingOpen;
        bool _swapping;
        bool _swapEnabled;
        uint256 _launchBlock;
        uint256 _minLockNum;
        mapping(address => undefined) lockData;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
