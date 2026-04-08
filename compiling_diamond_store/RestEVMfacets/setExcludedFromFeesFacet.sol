pragma solidity 0.8.24;
import "./TestLib.sol";
contract setExcludedFromFeesFacet {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function setExcludedFromFees(address account, bool excluded) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromFees[account] = excluded;
    }
}
