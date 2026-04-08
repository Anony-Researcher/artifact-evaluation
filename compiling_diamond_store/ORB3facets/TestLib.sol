/**

     ## ##   ### ##   ### ##    ## ##   
    ##   ##   ##  ##   ##  ##  ##   ##  
    ##   ##   ##  ##   ##  ##       ##  
    ##   ##   ## ##    ## ##      ###   
    ##   ##   ## ##    ##  ##       ##  
    ##   ##   ##  ##   ##  ##  ##   ##  
     ## ##   #### ##  ### ##    ## ##   

Telegram: https://link3.to/orb3pro
Twitter:  https://twitter.com/Orb3Tech
Website:  https://orb3.tech

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any _account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Math {
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface UniswapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface UniswapRouter {
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

interface safeErc20 {
    // Optimization Errors for ERC20
    error ERC20InvalidApprover(address Approver);
    error ERC20InvalidSpender(address Sender);
    error ERC20InvalidSender(address Sender);
    error ERC20InvalidReceiver(address Receiver);
    error ERC20ZeroTransfer();
}

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => bool) _excludedFromFee;
        mapping(address => bool) _pairAddress;
        string _name;
        string _symbol;
        uint8 _decimals;
        uint256 _totalSupply;
        uint256 maxTransaction;
        uint256 maxWallet;
        uint256 swapThreshold;
        uint256 _buyliquidityFee;
        uint256 _buyrewardsFee;
        uint256 _buyprojectFee;
        uint256 _sellliquidityFee;
        uint256 _sellrewardsFee;
        uint256 _sellprojectFee;
        uint256 buyFee;
        uint256 sellFee;
        uint256 feeDenominator;
        address marketingWallet;
        address rewardWallet;
        address developerWallet;
        bool swapEnabled;
        bool swapProtection;
        bool LimitsActive;
        bool TradeActive;
        UniswapRouter dexRouter;
        address dexPair;
        bool inSwap;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
