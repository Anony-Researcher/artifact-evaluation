// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import "./TestLib.sol";
contract isExcludedFromFeeFacet {
    using Address for address;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFee[account];
    }
}
