// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract removeBlacklistedFacet {
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

    function removeBlacklisted(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // To remove from the pre-built blacklist ONLY. Cannot add to blacklist.
        ds.initializer.removeBlacklisted(account);
    }
}
