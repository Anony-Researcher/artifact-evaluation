/**

.____                  .__                                _____  .___     _____ __________.___ 
|    |    __ __  _____ |__| ____   ____  __ __  ______   /  _  \ |   |   /  _  \\______   \   |
|    |   |  |  \/     \|  |/    \ /  _ \|  |  \/  ___/  /  /_\  \|   |  /  /_\  \|     ___/   |
|    |___|  |  /  Y Y  \  |   |  (  <_> )  |  /\___ \  /    |    \   | /    |    \    |   |   |
|_______ \____/|__|_|  /__|___|  /\____/|____//____  > \____|__  /___| \____|__  /____|   |___|
        \/           \/        \/                  \/          \/              \/              

Luminous Web3 is pioneering the seamless integration of payment processes through their advanced wallet API. 
This platform offers a unique blend of privacy, security, and efficiency for Web3 developers, making it effortless 
to connect to any wallet API. Its standout features include anonymous transactions on Solana, trusted third-party 
technology for secure transactions, multi-chain support, and an SDK designed for developers to build smarter payment systems easily. 
With just a few lines of code, businesses can streamline their payment systems, ensuring fast, secure, and versatile transactions across the globe. 
For more information, visit us. Lumin Technologies 

Website: https://www.luminousweb3.io/
X: https://x.com/luminousapi
Telegram Group: https://t.me/luminousapi
Telegram Support: https://t.me/luminoussupport
Telegram AI Calculation Bot: https://t.me/luminousaibot 

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

uint256 constant _initialBuyTax = 10;
uint256 constant _initialSellTax = 15;
uint256 constant _reduceBuyTaxAt = 20;
uint256 constant _reduceSellTaxAt = 30;
uint256 constant _preventSwapBefore = 25;
string constant _name = unicode"Luminous AI API";
string constant _symbol = unicode"Lumin";
uint8 constant _decimals = 18;
uint256 constant _tTotal = 10000000 * 10 ** _decimals;
uint256 constant _countTrigger = 20000 * 10 ** _decimals;
uint256 constant _taxSwapThreshold = 20000 * 10 ** _decimals;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _isExcludedFromFee;
        address payable _taxWallet;
        address uniswapV2Pair;
        IUniswapV2Router02 uniswapV2Router;
        uint256 _finalBuyTax;
        uint256 _finalSellTax;
        uint256 _buyCount;
        uint256 _countTax;
        uint256 _maxTaxSwap;
        uint256 _maxTxAmount;
        uint256 _maxWalletSize;
        bool tradingOpen;
        bool inSwap;
        bool swapEnabled;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
