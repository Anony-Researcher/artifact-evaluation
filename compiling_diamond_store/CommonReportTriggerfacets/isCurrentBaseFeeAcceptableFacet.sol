// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract isCurrentBaseFeeAcceptableFacet is Governance {
    function isCurrentBaseFeeAcceptable() external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address _baseFeeProvider = ds.baseFeeProvider;
        // If no provider is set return true.
        if (_baseFeeProvider == address(0)) return true;

        return
            IBaseFee(ds.baseFeeProvider).basefee_global() <=
            ds.acceptableBaseFee;
    }
}
