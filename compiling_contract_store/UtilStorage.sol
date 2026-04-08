// SPDX-License-Identifier: MIT

/*

This is a secure storage contract deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/storage

*/

pragma solidity 0.8.25;

interface IToken {
    function transfer(address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract UtilStorage {
    address private immutable owner;

    constructor(address account) {
        owner = account;
    }

    receive() external payable {
        depositETH();
    }

    function depositETH() public payable {
        require(msg.value > 0);
    }

    function withdrawETH(address to, uint256 amount) external {
        require(msg.sender == owner);
        (bool success,) = to.call{value: amount}("");
        require(success);
    }

    function withdrawToken(address token, address to, uint256 amount) external {
        require(msg.sender == owner);
        IToken(token).transfer(to, amount);
    }

    function balanceETH() external view returns (uint256) {
        return address(this).balance;
    }

    function balanceToken(address token) external view returns (uint256) {
        return IToken(token).balanceOf(address(this));
    }
}