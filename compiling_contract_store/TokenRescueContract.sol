// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenRescueContract {
    address public owner;

    constructor() {
        owner = msg.sender; // Set the deployer as the owner of the contract.
    }

    // Modifier to restrict function calls to the contract's owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "This function is restricted to the contract's owner.");
        _;
    }

    // Function to withdraw ERC-20 tokens sent to this contract.
    function rescueTokens(address tokenAddress, address to, uint256 amount) external onlyOwner {
        require(IERC20(tokenAddress).transfer(to, amount), "Token transfer failed.");
    }

    // Optional: Include a function to transfer ownership in case you want to change the owner.
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address.");
        owner = newOwner;
    }
}