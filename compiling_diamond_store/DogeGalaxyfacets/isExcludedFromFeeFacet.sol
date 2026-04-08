// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract isExcludedFromFeeFacet is ERC20 {
    using Address for address;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFee[account];
    }
}
