// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    event Withdraw(address indexed user, uint256 amount);
    function withdraw(uint256 depositIndex) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds._blacklisted[msg.sender],
            "You are not allowed to withdraw."
        );
        require(
            depositIndex < ds._deposits[msg.sender].length,
            "Invalid deposit index."
        );
        require(
            block.timestamp >=
                ds._deposits[msg.sender][depositIndex].depositTime +
                    ds._deposits[msg.sender][depositIndex].lockupPeriod,
            "Lockup period not over."
        );

        uint256 amountToWithdraw = ds
        ._deposits[msg.sender][depositIndex].amount;
        require(amountToWithdraw > 0, "No funds to withdraw.");

        ds._deposits[msg.sender][depositIndex].amount = 0;
        ds._totalWithdrawnAmounts[msg.sender] += amountToWithdraw; // Store the withdrawn amount
        ds._token.transfer(msg.sender, amountToWithdraw);

        emit Withdraw(msg.sender, amountToWithdraw);
    }
}
