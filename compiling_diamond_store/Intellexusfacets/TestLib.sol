// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/* @title The Intellective Collective
 * More info at: https://www.intellexuscollective.com
 *
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 */

abstract contract Context {
    /// @dev Returns the address of the current message sender, which is available for internal functions.
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/// @title ERC-20 Interface
/// @notice Interface for the compliance with the ERC-20 standard for fungible tokens.
interface IERC20 {
    /// @dev Returns the total token supply.
    function totalSupply() external view returns (uint256);

    /// @dev Returns the account balance of another account with address `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @dev Transfers `amount` tokens to address `recipient`, and MUST fire the `Transfer` event.
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /// @dev Returns the remaining number of tokens that the `spender` will be allowed to spend on behalf of `owner`.
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /// @dev Sets `amount` as the allowance of `spender` over the caller's tokens, and MUST fire the `Approval` event.
    function approve(address spender, uint256 amount) external returns (bool);

    /// @dev Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism and MUST fire the `Transfer` event.
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /// @notice Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    /// @dev MUST trigger when tokens are transferred, including zero value transfers.
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when the allowance of a `spender` for an `owner` is set by a call to `approve`.
    /// @dev MUST trigger on any successful call to `approve`.
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title Ownable
 * @dev A contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title IUniswapV2Factory
 * @dev Interface for Uniswap V2 Factory.
 */
interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

/**
 * @title IUniswapV2Router02
 * @dev Interface for Uniswap V2 Router.
 */
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

/**
 * @title Intellexus Token Contract
 * @dev Implements the {IERC20} interface with additional features such as ownership and fee management.
 */

string constant _name = "Intellexus";
string constant _symbol = "IXC";
uint8 constant _decimals = 9;
uint256 constant MAX = ~uint256(0);
uint256 constant _tTotal = 100000000 * 10 ** 9; // Total supply

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
