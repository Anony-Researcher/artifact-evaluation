/**
 */
/**
//  ..________...___________........__........_______....._______....______.........__.......___________........______....___........____..____..._______...
//  ./".......).("....._...")....../""\....../"......\.../"....."|../"._.."\......./""\.....("....._...")....../"._.."\..|"..|......(".._||_.".|.|..._.."\..
//  (:...\___/...)__/..\\__/....../....\....|:........|.(:.______).(:.(.\___)...../....\.....)__/..\\__/......(:.(.\___).||..|......|...(..).:.|.(..|_)..:).
//  .\___..\........\\_./......../'./\..\...|_____/...)..\/....|....\/.\........./'./\..\.......\\_./..........\/.\......|:..|......(:..|..|...).|:.....\/..
//  ..__/..\\.......|...|.......//..__'..\...//....../...//.___)_...//..\._.....//..__'..\......|...|..........//..\._....\..|___....\\.\__/.//..(|.._..\\..
//  ./".\...:)......\:..|....../.../..\\..\.|:..__...\..(:......"|.(:..._).\.../.../..\\..\.....\:..|.........(:..._).\..(.\_|:..\.../\\.__.//\..|:.|_)..:).
//  (_______/........\__|.....(___/....\___)|__|..\___)..\_______)..\_______).(___/....\___).....\__|..........\_______)..\_______).(__________).(_______/..
//  ........................................................................................................................................................
www.starecat.io 
https://t.me/starecatgang

Join the New Cat Revolution

Token Total Supply Breakdown: 100 Billion 
Public Sale: 40% (40 billion STC) To encourage widespread distribution and foster a strong initial user base
Community Rewards and Airdrops: 15% (15 billion STC) Aimed at rewarding the community for engagement, contributions, and early support
Team and Founders: 10% (10 billion STC) Tokens will be locked for 1 year, followed by a vesting period of 24-36 months to align team incentives with the long-term success of the project
10% (10 billion STC) Reserved for future collaborations, partnerships, and fostering the ecosystem’s growth
Reserve: 10% (10 billion STC) Held for unforeseen opportunities or emergencies, with usage governed by community vote
Marketing and Promotion: 8% (8 billion STC) Dedicated to global marketing efforts, promotional events, and community building.
Research and Development: 7% (7 billion STC) To fund continuous product development, innovation, and technological advancements.

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;
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

string constant _name = "Starecat";
string constant _symbol = "STC";
uint8 constant _decimals = 18;
uint256 constant MAX = ~uint256(0);
uint256 constant _tTotal = 100000000000 * 10 ** 18;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) _rOwned;
        mapping(address => uint256) _tOwned;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _isExcludedFromFee;
        uint256 _rTotal;
        uint256 _tFeeTotal;
        uint256 _redisFeeOnBuy;
        uint256 _taxFeeOnBuy;
        uint256 _redisFeeOnSell;
        uint256 _taxFeeOnSell;
        uint256 _redisFee;
        uint256 _taxFee;
        uint256 _previousredisFee;
        uint256 _previoustaxFee;
        mapping(address => bool) bots;
        mapping(address => uint256) _buyMap;
        mapping(address => bool) preTrader;
        address payable _developmentAddress;
        address payable _marketingAddress;
        IUniswapV2Router02 uniswapV2Router;
        address uniswapV2Pair;
        bool tradingOpen;
        bool inSwap;
        bool swapEnabled;
        uint256 _maxTxAmount;
        uint256 _maxWalletSize;
        uint256 _swapTokensAtAmount;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
