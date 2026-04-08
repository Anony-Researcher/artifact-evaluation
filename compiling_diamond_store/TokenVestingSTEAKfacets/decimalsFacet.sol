// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./TestLib.sol";
contract decimalsFacet {
    modifier onlyIfBeneficiaryExists(address beneficiary) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._holdersVestingCount[beneficiary] > 0,
            "TokenVestingSTEAK: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary"
        );
        _;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }
}
