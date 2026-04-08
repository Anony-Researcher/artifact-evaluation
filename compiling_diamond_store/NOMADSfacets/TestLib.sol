/*

$NOMADS

In the vast expanse of the post-apocalyptic wasteland where the Earth has stopped rotating plunging humanity into a perpetual day-night cycle, players embark on a journey of survival, conquest, and civilization-building in Nomads. 

As a lone wanderer known simply as the Nomad, players must navigate the harsh landscape, gathering resources and forging alliances to establish their own thriving settlements...

Socials
https://nomads.gitbook.io/nomads-gamefi/
https://t.me/PlayNOMADS
https://playnomads.com
https://twitter.com/PlayNOMADS

*/

pragma solidity 0.8.23;
// SPDX-License-Identifier: MIT

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

string constant _name = unicode"Nomads";
string constant _symbol = unicode"NOMADS";
uint8 constant _decimals = 18;
uint256 constant _tTotal = 1 * 1e6 * 10 ** _decimals;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _isExcludedFromFee;
        mapping(address => bool) whitelist;
        address payable _devWallet;
        address payable _marketingWallet;
        uint256 _BuyTax;
        uint256 _SellTax;
        uint256 _maxTxAmount;
        uint256 _maxWalletSize;
        uint256 _taxSwapThreshold;
        uint256 _maxTaxSwap;
        IUniswapV2Router02 uniswapV2Router;
        address uniswapV2Pair;
        bool tradingOpen;
        bool whitelistOn;
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
