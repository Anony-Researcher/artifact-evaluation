// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getAllVestingsFacet is ERC20 {
    using SafeMath for uint256;

    function getAllVestings()
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 length = ds.vestingBeneficiaries.length;
        address[] memory beneficiaries = new address[](length);
        uint256[] memory balances = new uint256[](length);
        uint256[] memory startTimes = new uint256[](length);
        uint256[] memory cliffDurations = new uint256[](length);
        uint256[] memory durations = new uint256[](length);
        uint256[] memory slicePeriods = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            address beneficiary = ds.vestingBeneficiaries[i];
            beneficiaries[i] = beneficiary;
            balances[i] = ds.vestingData[beneficiary].balance;
            startTimes[i] = ds.vestingData[beneficiary].startTime;
            cliffDurations[i] = ds.vestingData[beneficiary].cliffDuration;
            durations[i] = ds.vestingData[beneficiary].duration;
            slicePeriods[i] = ds.vestingData[beneficiary].slicePeriod;
        }

        return (
            beneficiaries,
            balances,
            startTimes,
            cliffDurations,
            durations,
            slicePeriods
        );
    }
}
