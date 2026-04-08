/**
 *Submitted for verification at Etherscan.io on 2023-11-19
 */

//SPDX-License-Identifier: Unlicensed

/* 

 _______  _______  _______  ___  
|       ||       ||       ||   | 
|    _  ||    ___||    _  ||   | 
|   |_| ||   |___ |   |_| ||   | 
|    ___||    ___||    ___||   | 
|   |    |   |___ |   |    |   | 
|___|    |_______||___|    |___| 

*/

pragma solidity 0.8.21;

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

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

interface IDEXFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IPancakePair {
    function sync() external;
}

interface IDEXRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

address constant DEAD = 0x000000000000000000000000000000000000dEaD;
address constant ZERO = 0x0000000000000000000000000000000000000000;
uint8 constant _decimals = 9;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        address WETH;
        string _name;
        string _symbol;
        uint256 _totalSupply;
        uint256 _maxTxAmount;
        uint256 _maxWalletSize;
        mapping(address => uint256) _rOwned;
        uint256 _totalProportion;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) isCooldownExempt;
        mapping(address => bool) isFeeExempt;
        mapping(address => bool) isTxLimitExempt;
        uint256 liquidityFeeBuy;
        uint256 liquidityFeeSell;
        uint256 TeamFeeBuy;
        uint256 TeamFeeSell;
        uint256 marketingFeeBuy;
        uint256 marketingFeeSell;
        uint256 reflectionFeeBuy;
        uint256 reflectionFeeSell;
        uint256 totalFeeBuy;
        uint256 totalFeeSell;
        uint256 feeDenominator;
        address autoLPReceiver;
        address marketingReceiver;
        address teamReceiver;
        uint256 targetLiquidity;
        uint256 targetLiquidityDenominator;
        IDEXRouter router;
        address pair;
        bool tradingOpen;
        bool buyCooldownEnabled;
        uint8 CooldownTimerInterval;
        mapping(address => uint) CooldownTimer;
        bool claimingFees;
        bool alternateSwaps;
        uint256 smallSwapThreshold;
        uint256 largeSwapThreshold;
        uint256 swapThreshold;
        bool inSwap;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
