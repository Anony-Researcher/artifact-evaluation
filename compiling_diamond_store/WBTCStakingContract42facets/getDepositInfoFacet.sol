// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getDepositInfoFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    function getDepositInfo(
        address user
    )
        external
        view
        returns (
            uint256[] memory depositIndices,
            uint256[] memory unlockTimes,
            uint256[] memory stakedAmounts,
            uint256[] memory lockupPeriods
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 depositCount = ds._deposits[user].length;

        depositIndices = new uint256[](depositCount);
        unlockTimes = new uint256[](depositCount);
        stakedAmounts = new uint256[](depositCount);
        lockupPeriods = new uint256[](depositCount);

        for (uint256 i = 0; i < depositCount; i++) {
            depositIndices[i] = i;
            unlockTimes[i] =
                ds._deposits[user][i].depositTime +
                ds._deposits[user][i].lockupPeriod;
            stakedAmounts[i] = ds._deposits[user][i].amount;
            lockupPeriods[i] = ds._deposits[user][i].lockupPeriod;
        }
    }
}
