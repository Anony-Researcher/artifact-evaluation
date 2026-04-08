// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract batchTransferActualFacet {
    function batchTransferActual(
        address[] calldata recipients,
        uint256 amount
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 senderBalance = ds._balances[msg.sender];
        uint256 totalAmount = amount * recipients.length;

        require(senderBalance >= totalAmount, "Insufficient balance");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(
                recipient != address(0),
                "Cannot transfer to the zero address"
            );
            ds._balances[msg.sender] -= amount;
            ds._balances[recipient] += amount;

            emit Transfer(msg.sender, recipient, amount);
        }
    }
}
