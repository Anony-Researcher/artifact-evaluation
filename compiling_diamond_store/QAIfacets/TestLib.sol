// SPDX-License-Identifier: Unlicensed

/*
Quiz AI gives you the ability to choose from our preselected trivia topics or you can create ANY trivia topic you want and our AI-powered bot will  generate a challenging trivia quiz tailored just for you, your friends or your crypto project's community.

You can play for money, rewards, tokens, whitelists and more. Choose from 3 different quiz modes: 

- Project Mode: A unique competition bot for your crypto project's community
- Group Mode: Test your skills against a group of users or friends
- Player vs. Player Mode: Challenge one other person to see who has the biggest brain.

Welcome to the next generation of Quiz and Trivia Competition Bots.

Web: https://quizai.fun
Tg: https://t.me/quiz_ai_erc_official
X: https://twitter.com/Quiz_AI_X
Bot: https://t.me/QuizBot
*/

pragma solidity 0.8.19;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IUniswapFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function set(address) external;
    function setSetter(address) external;
}

interface IUniswapRouter {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

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

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        uint8 decimals_;
        uint256 _supply;
        string name_;
        string symbol_;
        IUniswapRouter routerInstance_;
        address pairAddress_;
        uint256 _txLiquidityFee_;
        uint256 _txMarketingFee_;
        uint256 _txDevelopmentFee_;
        uint256 _txTotalFee_;
        uint256 _sizeTxMax;
        uint256 _sizeWalletMax;
        uint256 _threshFee;
        uint256 _purQAILiquidityFee_;
        uint256 _purQAIMarketingFee_;
        uint256 _purQAIDevFee_;
        uint256 _purQAIFee_;
        address payable devAddress1_;
        address payable devAddress2_;
        uint256 sellQAILiquidityFee_;
        uint256 sellQAIMarketingFee_;
        uint256 sellQAIDevFee_;
        uint256 sellQAIFee_;
        mapping(address => uint256) balances_;
        mapping(address => mapping(address => uint256)) allowances_;
        mapping(address => bool) _isTaxNo;
        mapping(address => bool) _isMWalletNo;
        mapping(address => bool) _isNoMTx;
        mapping(address => bool) _isLPAdder;
        bool _isGuarded;
        bool _swapTaxActivated;
        bool _maxTxDeActivated;
        bool _maxWalletInEffect;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
