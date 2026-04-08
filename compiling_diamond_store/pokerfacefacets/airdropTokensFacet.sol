// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract airdropTokensFacet {
    function airdropTokens(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(recipients.length == amounts.length, "Mismatched input arrays");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Airdrop to the zero address");
            uint256 adjustedAmount = amounts[i] * (10 ** ds.decimals);
            require(
                adjustedAmount <= ds.balanceOf[msg.sender],
                "Caller does not have enough tokens"
            );

            ds.balanceOf[msg.sender] -= adjustedAmount;
            ds.balanceOf[recipients[i]] += adjustedAmount;

            emit Transfer(msg.sender, recipients[i], adjustedAmount);
        }
    }
}
