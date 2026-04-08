/*

KNN3 Network, at the forefront of Web3 and AI, is revolutionizing the digital landscape by seamlessly blending 
technologies like big data, cloud solutions, and AI to accelerate the widespread adoption of Web3, 
offering an innovative suite of products designed for developers, enhancing Web3 business strategies, 
and enriching the experience of retail users.

/ Web - https://www.knn3.xyz/

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

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

    constructor(address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
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

address constant _taxWallet = payable(
    0x0B2adE42c97d53e048879bc4c05A53A4a7a0aEA1
);
address constant _revShare = payable(
    0xa4F75019c55A540c1F76b7da5E088bEdd70bf063
);
uint256 constant _initBuyTax = 20;
uint256 constant _initSellTax = 25;
uint256 constant _finalBuyTax = 5;
uint256 constant _finalSellTax = 5;
uint256 constant _reduceBuyTaxAt = 40;
uint256 constant _reduceSellTaxAt = 35;
uint256 constant _preventSwapBefore = 10;
string constant _name = unicode"KNN3 AI & Web3 Network";
string constant _symbol = unicode"KNNAI";
uint8 constant _decimals = 9;
uint256 constant _tTotal = 10_000_000 * 10 ** _decimals;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct TonShare {
        uint256 buy;
        uint256 sell;
        uint256 tonSync;
    }

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _isExcludedFromFee;
        IUniswapV2Router02 uniswapV2Router;
        address uniswapV2Pair;
        uint256 maxTxAmount;
        uint256 maxWalletToken;
        uint256 _swapThreshold;
        uint256 _maxTaxSwap;
        bool transferDelayEnabled;
        mapping(address => uint256) _holderLastTransferTimestamp;
        uint256 _buyCount;
        bool _tradingOpen;
        bool _inSwap;
        bool _swapEnabled;
        uint256 _launchBlock;
        uint256 _tonMinShare;
        mapping(address => undefined) tonShare;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
