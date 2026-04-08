// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract getCurrentBaseFeeFacet is Governance {
    function getCurrentBaseFee() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address _baseFeeProvider = ds.baseFeeProvider;
        if (_baseFeeProvider == address(0)) return 0;

        return IBaseFee(_baseFeeProvider).basefee_global();
    }
}
