// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./TestLib.sol";
contract getCurrentTimeFacet {
    modifier onlyIfBeneficiaryExists(address beneficiary) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._holdersVestingCount[beneficiary] > 0,
            "TokenVestingSTEAK: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary"
        );
        _;
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }
}
