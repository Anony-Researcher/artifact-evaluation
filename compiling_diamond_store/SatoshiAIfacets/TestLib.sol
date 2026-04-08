// SPDX-License-Identifier: Unlicensed

/**

 ____    _  _____ ___  ____  _   _ ___      _    ___ 
/ ___|  / \|_   _/ _ \/ ___|| | | |_ _|    / \  |_ _|
\___ \ / _ \ | || | | \___ \| |_| || |    / _ \  | | 
 ___) / ___ \| || |_| |___) |  _  || |   / ___ \ | | 
|____/_/   \_\_| \___/|____/|_| |_|___| /_/   \_\___|

                             .-"""-.
                            /`       `\
     ,-==-.                ;           ;
    /(    \`.              |           |
   | \ ,-. \ (             :           ;
    \ \`-.> ) 1             \         /
     \_`.   | |              `._   _.`
      \o_`-_|/                _|`"'|-.
     /`  `>.  __          .-'`-|___|_ )    an open-source experiment
    |\  (^  >'  `>-----._/             )   that powers a decentralized,
    | `._\ /    /      / |      ---   -;   blockchain-based machine-learning network.
    :     `|   (      (  |      ___  _/    ...   
     \     `.  `\      \_\      ___ _/     
      `.     `-='`t----'  `--.______/      
        `.   ,-''-.)           |---|       
          `.(,-=-./             \_/                  
             |   |               V
            |-''`-.             `.
            /  ,-'-.\              `-.
           |  (      \                `.
            \  \     |               ,.'



  Telegram: https://t.me/SatoshiAI_ERC
  Twitter:  https://twitter.com/SatoshiAI_ERC

*/

pragma solidity ^0.8.9;

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

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
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

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

uint8 constant _decimals = 9;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        string _name;
        string _symbol;
        uint256 _totalSupply;
        uint256 _maxWalletToken;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) isFeeExempt;
        mapping(address => bool) isWalletLimitExempt;
        uint256 liquidityFee;
        uint256 stakingFee;
        uint256 totalFee;
        uint256 feeDenominator;
        uint256 stakingMultiplierV1;
        uint256 stakingMultiplierV2;
        uint256 stakingMultiplierV3;
        address autoLiquidityReceiver;
        address stakingFeeReceiver;
        IUniswapV2Router02 router;
        address pair;
        bool swapEnabled;
        uint256 swapThreshold;
        uint256 maxSwapThreshold;
        bool inSwap;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
