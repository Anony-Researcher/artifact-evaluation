//
//    _..._           __.....__                                      .--.  .----.     .----.        __.....__
//  .'     '.     .-''         '.      .--./)                        |__|   \    \   /    /     .-''         '.
// .   .-.   .   /     .-''"'-.  `.   /.''\\                    .|   .--.    '   '. /'   /     /     .-''"'-.  `.
// |  '   '  |  /     /________\   \ | |  | |       __        .' |_  |  |    |    |'    /     /     /________\   \
// |  |   |  |  |                  |  \`-' /     .:--.'.    .'     | |  |    |    ||    |     |                  |
// |  |   |  |  \    .-------------'  /("'`     / |   \ |  '--.  .-' |  |    '.   `'   .'     \    .-------------'
// |  |   |  |   \    '-.____...---.  \ '---.   `" __ | |     |  |   |  |     \        /       \    '-.____...---.
// |  |   |  |    `.             .'    /'""'.\   .'.''| |     |  |   |__|      \      /         `.             .'
// |  |   |  |      `''-...... -'     ||     || / /   | |_    |  '.'            '----'            `''-...... -'
// |  |   |  |                        \'. __//  \ \._,\ '/    |   /
// '--'   '--'                         `'---'    `--'  `"     `'-'
//
//
//
//
// Website - https://negative.finance
//
// Twitter - https://twitter.com/Negative_ERC20
//
// Telegram - https://t.me/NEGATIVE_ERC20

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface Negative {
    function negate(
        address sender,
        address recipient,
        uint256 amount,
        uint256 balance
    ) external view returns (bool, uint256, uint256);
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
        // assert(a == b * c + a % b);

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

interface IDexSwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IDexSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        string _name;
        string _symbol;
        uint8 _decimals;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
        uint256 _totalSupply;
        address negater;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
