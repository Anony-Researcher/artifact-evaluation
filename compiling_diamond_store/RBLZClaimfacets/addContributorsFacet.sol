// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract addContributorsFacet is Pausable {
    using SafeERC20 for IERC20;

    event ContributorAdded(address account, uint256 amount, uint256 stageId);
    event AmountClaimed(address account, uint256 amount);
    event NewRebelSatoshiToken(address newRebelSatoshi);
    function addContributors(
        address[] calldata accounts,
        uint256[] calldata amounts,
        uint256[] calldata startDates
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            accounts.length == amounts.length,
            "Array lengths do not match"
        );
        require(
            accounts.length == startDates.length,
            "Start date array length does not match"
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            ds.vestings[accounts[i]] = TestLib.VestingDetails({
                totalAmount: amounts[i] * (10 ** 18),
                claimedAmount: 0,
                startTime: startDates[i]
            });
            ds.totalContribution += amounts[i];
            emit ContributorAdded(accounts[i], amounts[i], 0); // StageId is removed
        }
    }
    function updateStartDateForContributor(
        address account,
        uint256 newStartDate
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.vestings[account].totalAmount > 0,
            "Contributor does not exist"
        );
        ds.vestings[account].startTime = newStartDate;
    }
    function setMaxWeeksForVesting(uint256 _maxWeeks) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWeeksForVesting = _maxWeeks;
    }
    function claim() external whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address caller = _msgSender();
        require(
            block.timestamp >= ds.vestings[caller].startTime,
            "Claiming not allowed yet"
        );
        uint256 vestedAmount = calculateVestedAmount(caller);
        require(vestedAmount > 0, "No balance to claim");

        ds.vestings[caller].claimedAmount += vestedAmount;
        IERC20(ds.rebelSatoshi).safeTransfer(caller, vestedAmount);

        emit AmountClaimed(caller, vestedAmount);
    }
    function updateRebelSatoshiToken(address newAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newAddress != address(0), "Zero address");
        ds.rebelSatoshi = newAddress;
        emit NewRebelSatoshiToken(newAddress);
    }
    function pause() external onlyOwner {
        _pause();
    }
    function unpause() external onlyOwner {
        _unpause();
    }
    function calculateVestedAmount(
        address account
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.VestingDetails memory vesting = ds.vestings[account];
        if (block.timestamp < vesting.startTime) {
            return 0;
        }

        uint256 weeksElapsed = (block.timestamp - vesting.startTime) / 1 weeks;
        weeksElapsed = weeksElapsed > ds.maxWeeksForVesting
            ? ds.maxWeeksForVesting
            : weeksElapsed;
        uint256 totalVestedAmount = (vesting.totalAmount /
            ds.maxWeeksForVesting) * weeksElapsed;

        return totalVestedAmount - vesting.claimedAmount;
    }
}
