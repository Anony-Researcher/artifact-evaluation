pragma solidity ^0.4.17;
import "./TestLib.sol";
contract addLockFacet is Pausable, StandardToken, BlackList {
    function addLock(
        address user,
        uint256 initialLockAmount,
        uint256 lockAmount,
        uint256 releaseStart,
        uint256 releaseInterval,
        uint256 releasePeriods
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.LockInfo storage info = ds.lockInfos[user];
        require(info.lockAmount == 0); // Make sure the lock is not set
        ds.lockInfos[user] = TestLib.LockInfo(
            initialLockAmount,
            lockAmount,
            releaseStart,
            releaseInterval,
            0,
            releasePeriods
        );
    }
}
