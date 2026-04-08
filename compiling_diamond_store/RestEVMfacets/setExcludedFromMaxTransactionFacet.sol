pragma solidity 0.8.24;
import "./TestLib.sol";
contract setExcludedFromMaxTransactionFacet {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function setExcludedFromMaxTransaction(
        address account,
        bool excluded
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedMaxTransactionAmount[account] = excluded;
    }
}
