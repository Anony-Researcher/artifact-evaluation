// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: czee/CZEEAirdrop.sol


pragma solidity ^0.8.20;



contract CZEEAirdrop is Ownable {

    IERC20 public token;

    uint256 public airdropPerAccountAmount;
    uint256 public maxAirdropsAmount;
    uint256 public releasedAirdropAmount;
    uint256 public remainigAirdropAmount;

    uint256 public airdropStartTime;
    uint256 public airdropEndTime;
    uint256 public airdropDuration;

    bool public isStarted;

    mapping(address => bool) public isInAirdropList;

    constructor() Ownable(msg.sender) {}

    //------------------
    // Admin Functions
    //------------------

    /*
        1. Owner calls this function to put airdrop tokens into contract.
            Owner needs to call the token's approve() function before call depositTokens()
            approve(CZEEAirdrop.address, _amount)
    */
    function depositTokens(address _token, uint256 _amount) public onlyOwner {
        token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _amount);

        maxAirdropsAmount += _amount;
    }

    /* 
        2. Owner calls this function to start the airdrop.
            _airdropDeadline:             days remain to airdrop deadline
            _airdropPerAccountAmount:     ex. 100e18 ~ 100000000000000000000
    */
    function startAirdrop(uint256 _airdropDeadline, uint256 _airdropPerAccountAmount) public onlyOwner {
        require(!isStarted, "Airdrop has been started already!");
        require(maxAirdropsAmount > 0, "Add tokens to the contract, before starting the Airdrop");

        airdropDuration = _airdropDeadline * 1 days;
        airdropPerAccountAmount = _airdropPerAccountAmount;

        airdropStartTime = block.timestamp;
        airdropEndTime = airdropStartTime + airdropDuration;

        isStarted = true;
        remainigAirdropAmount = maxAirdropsAmount;
    }

    // 3. The owner calls this function to batch send airdrop tokens
    function sendAirdrops(address[] memory acs) public onlyOwner {
        require(isStarted, "Airdrop hasn't started yet!");

        for(uint i; i<acs.length; i++) {
            address acc = acs[i];
            // If the account isn't already on the airdrop list!
            if(!isInAirdropList[acc])
                sendAirdropToAcc(acc);
        }
    }

    // transfer airdrop tokens to an address and put it in the airdrop list
    function sendAirdropToAcc(address acc) internal {
        require(releasedAirdropAmount < maxAirdropsAmount);
        require(remainigAirdropAmount >= airdropPerAccountAmount, "Not enough tokens for airdrop");

        token.transfer(acc, airdropPerAccountAmount);

        isInAirdropList[acc] = true;
        remainigAirdropAmount -= airdropPerAccountAmount;
        releasedAirdropAmount += airdropPerAccountAmount;
    }

    // 4. The owner calls this function to withdraw the remaining tokens in the contract.
    function withdrawTokens(uint amount) public onlyOwner {
        require(amount <= getAirdripTokensBalance(), "Not enough token");
        token.transfer(msg.sender, amount);
    }

    //------------------
    // get Functions
    //------------------

    function IsAccInAirdropList(address acc) public view returns(bool) {
        return isInAirdropList[acc];
    }

    function getAirdropPerAccountAmount() public view returns(uint256) {
        return airdropPerAccountAmount;
    }

    function getAirdripTokensBalance() public view returns(uint256) {
        return token.balanceOf(address(this));
    }
}