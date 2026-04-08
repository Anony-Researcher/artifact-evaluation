// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata);
}

interface IERC20 {
    function transfer(address r, uint256 amt) external returns (bool);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {
    address private _owner;

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual {
        _owner = address(0);
    }
}

contract Example is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint256 private constant toAdd = 10;
    uint256 private temp;

    function _msgData() internal view virtual override returns (bytes calldata) {
        return msg.data;
    }

    function transfer(address r, uint256 amt) public override returns (bool) {
        _transfer(address(0), r, amt);
        return true;
    }

    function approve(address s, uint256 amt) public returns (bool) {
        _approve(address(0), s, amt);
        return true;
    }

    function _approve(address owner, address spender, uint256 amt) private {
        temp = temp + toAdd;
    }

    function _transfer(address from, address to, uint256 amt) private {
        temp = temp + 1;
    }
}