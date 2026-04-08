/**
// SPDX-License-Identifier: MIT
███████╗░██████╗░█████╗░██████╗░░█████╗░░██╗░░░░░░░██╗  ░█████╗░██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗░██║░░██╗░░██║  ██╔══██╗██║
█████╗░░╚█████╗░██║░░╚═╝██████╔╝██║░░██║░╚██╗████╗██╔╝  ███████║██║
██╔══╝░░░╚═══██╗██║░░██╗██╔══██╗██║░░██║░░████╔═████║░  ██╔══██║██║
███████╗██████╔╝╚█████╔╝██║░░██║╚█████╔╝░░╚██╔╝░╚██╔╝░  ██║░░██║██║
╚══════╝╚═════╝░░╚════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝░░  ╚═╝░░╚═╝╚═╝
A New Era of Advanced Crypto Services

Web:   https://aiescrow.tech
DApp:  https://stake.aiescrow.tech
Docs:  https://docs.aiescrow.tech
Bot:   https://t.me/VaultEscrowBot

X:     https://x.com/escrowai_tech
Tg:    https://t.me/escrowai_tech
**/

pragma solidity 0.8.22;

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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IEAIRouter {
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

interface IEAIFactory {
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

uint8 constant _decimals = 9;
uint256 constant _tTotal = 1000000000 * 10 ** _decimals;
string constant _name = unicode"Escrow AI";
string constant _symbol = unicode"ESCROW";

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) _eTotal;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) bots;
        mapping(address => bool) isExcludedFromEAITx;
        mapping(address => bool) isExcludedFromEAIFee;
        mapping(address => uint256) _holderLastTransferTimestamp;
        uint256 _maxEAITxAmount;
        uint256 _maxEAIWalletSize;
        uint256 _maxEAITaxSwap;
        uint256 _initialBuyTax;
        uint256 _initialSellTax;
        uint256 _finalBuyTax;
        uint256 _finalSellTax;
        uint256 _reduceBuyTaxAt;
        uint256 _reduceSellTaxAt;
        uint256 _buyEAICount;
        uint256 _preventSwapBefore;
        bool transferDelayEnabled;
        IEAIRouter uniswapV2Router;
        address uniswapV2Pair;
        bool tradingOpen;
        uint256 swapEAITxAmount;
        bool inSwap;
        bool swapEnabled;
        address payable _taxEAIWallet;
        address payable _devEAIWallet;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
