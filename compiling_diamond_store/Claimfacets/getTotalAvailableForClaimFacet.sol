// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getTotalAvailableForClaimFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not ds.owner");
        _;
    }

    function getTotalAvailableForClaim(
        address userAddress,
        uint256 presaleAmount,
        uint256 airdropAmount
    ) public view returns (uint256 totalAvailable) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Allocation storage userAllocation = ds.allocations[userAddress];

        if (ds.startTime > block.timestamp) {
            return totalAvailable = 0;
        }

        uint256 monthsElapsed = (block.timestamp - ds.startTime) / ONE_MONTH;
        uint256 availableAirdrop = 0;
        uint256 availablePresale = 0;

        bool hasClaimedInitial = userAllocation.hasClaimedInitial;
        uint256 userPresaleAmount = hasClaimedInitial
            ? userAllocation.presale
            : presaleAmount;
        uint256 userAirdropAmount = hasClaimedInitial
            ? userAllocation.airdrop
            : airdropAmount;

        if (
            !hasClaimedInitial &&
            block.timestamp <= ds.startTime + AirdropForfeit
        ) {
            availableAirdrop = userAirdropAmount;
        }

        if (hasClaimedInitial) {
            uint256 totalClaimablePresale = (userPresaleAmount *
                INITIAL_RELEASE_PERCENTAGE) /
                10000 +
                ((monthsElapsed *
                    MONTHLY_RELEASE_PERCENTAGE *
                    userPresaleAmount) / 10000);
            totalClaimablePresale = totalClaimablePresale > userPresaleAmount
                ? userPresaleAmount
                : totalClaimablePresale;
            availablePresale =
                totalClaimablePresale -
                userAllocation.claimedPresale;
        } else if (monthsElapsed > 0) {
            uint256 initialPresaleRelease = (userPresaleAmount *
                INITIAL_RELEASE_PERCENTAGE) / 10000;
            uint256 totalClaimablePresale = initialPresaleRelease +
                ((monthsElapsed *
                    MONTHLY_RELEASE_PERCENTAGE *
                    userPresaleAmount) / 10000);
            totalClaimablePresale = totalClaimablePresale > userPresaleAmount
                ? userPresaleAmount
                : totalClaimablePresale;
            availablePresale = totalClaimablePresale;
        } else {
            availablePresale =
                (userPresaleAmount * INITIAL_RELEASE_PERCENTAGE) /
                10000;
        }

        totalAvailable = availableAirdrop + availablePresale;
    }
    function claim(uint256 airdropAmount, uint256 presaleAmount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.startTime != 0 && block.timestamp >= ds.startTime,
            "Vesting has not started or start time not set"
        );

        uint256 totalAvailable = getTotalAvailableForClaim(
            msg.sender,
            presaleAmount,
            airdropAmount
        );
        require(totalAvailable > 0, "No tokens available for claim");

        TestLib.Allocation storage userAllocation = ds.allocations[msg.sender];

        if (!userAllocation.hasClaimedInitial) {
            userAllocation.hasClaimedInitial = true;

            uint256 monthsElapsed = (block.timestamp - ds.startTime) /
                ONE_MONTH;

            uint256 totalClaimablePresale = 0;
            if (monthsElapsed >= 1) {
                totalClaimablePresale =
                    ((presaleAmount * INITIAL_RELEASE_PERCENTAGE) / 10000) +
                    ((monthsElapsed *
                        MONTHLY_RELEASE_PERCENTAGE *
                        presaleAmount) / 10000);
            } else {
                totalClaimablePresale =
                    (presaleAmount * INITIAL_RELEASE_PERCENTAGE) /
                    10000;
            }
            totalClaimablePresale = totalClaimablePresale > presaleAmount
                ? presaleAmount
                : totalClaimablePresale;

            if (airdropAmount > 0) {
                uint256 totalInitialClaim = airdropAmount +
                    totalClaimablePresale;
                require(
                    totalInitialClaim <= ds.token.balanceOf(address(this)),
                    "Insufficient tokens in contract"
                );
                ds.token.transfer(msg.sender, totalInitialClaim);
                userAllocation.claimedAirdrop += airdropAmount;
                userAllocation.claimedPresale += totalClaimablePresale;
                userAllocation.airdrop += airdropAmount;
                userAllocation.presale += presaleAmount;
            } else {
                require(
                    totalClaimablePresale <= ds.token.balanceOf(address(this)),
                    "Insufficient tokens in contract"
                );
                ds.token.transfer(msg.sender, totalClaimablePresale);
                userAllocation.claimedPresale += totalClaimablePresale;
                userAllocation.presale += presaleAmount;
                userAllocation.airdrop += airdropAmount;
            }
        } else {
            uint256 monthsElapsed = (block.timestamp - ds.startTime) /
                ONE_MONTH;
            uint256 totalClaimablePresale = (userAllocation.presale *
                INITIAL_RELEASE_PERCENTAGE) /
                10000 +
                ((monthsElapsed *
                    MONTHLY_RELEASE_PERCENTAGE *
                    userAllocation.presale) / 10000);
            totalClaimablePresale = totalClaimablePresale >
                userAllocation.presale
                ? userAllocation.presale
                : totalClaimablePresale;

            uint256 presaleToDistribute = totalClaimablePresale -
                userAllocation.claimedPresale;
            if (presaleToDistribute > 0) {
                require(
                    presaleToDistribute <= ds.token.balanceOf(address(this)),
                    "Insufficient tokens in contract"
                );
                ds.token.transfer(msg.sender, presaleToDistribute);
                userAllocation.claimedPresale += presaleToDistribute;
            }
        }
    }
}
