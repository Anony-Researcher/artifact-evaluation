//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract getValidStakingDurationsFacet is DividendTracker, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    function getValidStakingDurations()
        external
        view
        returns (uint256[] memory)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.stakingPeriodsInDays.values();
    }
}
