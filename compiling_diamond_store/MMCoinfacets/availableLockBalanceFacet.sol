pragma solidity ^0.4.17;
import "./TestLib.sol";
contract availableLockBalanceFacet is Pausable, StandardToken, BlackList {
    function availableLockBalance(
        address user
    ) public view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.LockInfo storage info = ds.lockInfos[user];

        if (block.timestamp < info.releaseStart) {
            // If the current time has not reached the first release time, all tokens are still locked
            return (info.initialLockAmount, info.releasePeriods);
        }

        // Calculate the elapsed release period
        uint256 elapsedPeriods = (block.timestamp.sub(info.releaseStart)).div(
            info.releaseInterval
        );

        // Remaining release period
        uint256 remainingPeriods = elapsedPeriods >= info.releasePeriods
            ? 0
            : info.releasePeriods.sub(elapsedPeriods);

        // Count the number of tokens released
        uint256 released = info.initialLockAmount.mul(elapsedPeriods).div(
            info.releasePeriods
        );

        // Number of remaining lock-up tokens
        uint256 remainingLockBalance = info.initialLockAmount.sub(released);

        return (remainingLockBalance, remainingPeriods);
    }
}
