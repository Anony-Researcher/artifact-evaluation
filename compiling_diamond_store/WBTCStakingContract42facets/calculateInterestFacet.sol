// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract calculateInterestFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    event InterestClaimed(address indexed user, uint256 amount);
    function calculateInterest(
        address user,
        uint256 depositIndex
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        DepositInfo storage deposit = ds._deposits[user][depositIndex];
        uint256 interestClaimed = ds._deposits[user][depositIndex].amount -
            ds._deposits[user][depositIndex].amount;
        uint256 timeElapsed = block.timestamp - deposit.lastClaimTime;
        uint256 interest = (deposit.amount *
            deposit.interestRate *
            timeElapsed) / (100000000000000000 * 86400); // 86400 seconds in a day
        return interest + interestClaimed;
    }
    function claimInterestForDeposit(uint256 lockupPeriod) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            !ds._blacklisted[msg.sender],
            "You are not allowed to claim interest."
        );

        uint256 totalInterestToClaim = 0;

        for (uint256 i = 0; i < ds._deposits[msg.sender].length; i++) {
            if (
                ds._deposits[msg.sender][i].lockupPeriod ==
                lockupPeriod * 1 days
            ) {
                uint256 interestToClaim = calculateInterest(msg.sender, i);
                require(interestToClaim > 0, "No interest to claim.");

                ds._deposits[msg.sender][i].lastClaimTime = block.timestamp;
                totalInterestToClaim += interestToClaim;
            }
        }

        ds._token.transfer(msg.sender, totalInterestToClaim);

        emit InterestClaimed(msg.sender, totalInterestToClaim);
    }
}
