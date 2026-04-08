// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./TestLib.sol";
contract getVestingIdAtIndexFacet {
    modifier onlyIfBeneficiaryExists(address beneficiary) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._holdersVestingCount[beneficiary] > 0,
            "TokenVestingSTEAK: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary"
        );
        _;
    }

    function getVestingIdAtIndex(
        uint256 index
    ) external view returns (bytes32) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            index < getVestingSchedulesCount(),
            "TokenVestingSTEAK: index out of bounds"
        );

        return ds._vestingSchedulesIds[index];
    }
    function getVestingSchedulesCount() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._vestingSchedulesIds.length;
    }
}
