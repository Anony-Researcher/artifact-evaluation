// SPDX-License-Identifier: MIT

/**

In the cryptoverse's arena, Puppy the AI, a guardian of digital realms, 
faced off against Floki and Shiba Inu, 
titans of meme coin fame. Unlike any ordinary Scottish Terrier, 
Puppy's jet-black fur and advanced AI made him a formidable opponent. 
This wasn't just a clash; it was a showdown of wit over might. 
Puppy, with his deep understanding of the blockchain's intricacies, 
outmaneuvered the duo, safeguarding the cryptoverse's balance. 
His victory wasn't about dominance but ensuring the digital world remained a place for all,
showcasing his role not just as a protector but as a wise guardian always steps ahead.

Website:  https://www.puppyai.tech
Telegram: https://t.me/puppyai_erc
Twitter:  https://twitter.com/puppyai_erc

**/

pragma solidity 0.8.18;

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

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

interface IDEXFactory {
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

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

uint8 constant _decimals = 9;
uint256 constant _tTotal = 1_000_000_000 * 10 ** _decimals;
string constant _name = unicode"Puppy AI";
string constant _symbol = unicode"PUPPY";
address constant deadWallet = 0x000000000000000000000000000000000000dEaD;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) pupValues;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) excludedFromFees;
        IDEXRouter uniswapV2Router;
        address uniswapV2Pair;
        bool inSwapLP;
        bool tradeEnabled;
        bool swapEnabled;
        uint256 txMaxLimits;
        uint256 minSwapCounts;
        uint256 maxSwapCounts;
        uint256 _buyMAXs;
        uint256 _buyTAXs;
        uint256 _sellTAXs;
        address payable opSender;
        address payable pupSender;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
