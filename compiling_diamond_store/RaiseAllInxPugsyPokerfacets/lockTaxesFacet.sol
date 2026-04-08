// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract lockTaxesFacet {
    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._owner == msg.sender, "Caller =/= owner.");
        _;
    }

    function lockTaxes() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // This will lock taxes at their current value forever, do not call this unless you're sure.
        ds.taxesAreLocked = true;
    }
}
