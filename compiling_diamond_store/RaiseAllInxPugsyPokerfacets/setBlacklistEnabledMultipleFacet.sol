// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract setBlacklistEnabledMultipleFacet {
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

    function setBlacklistEnabledMultiple(
        address[] memory accounts,
        bool enabled
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Cannot blacklist contract, LP pair, or anything that would otherwise stop trading entirely.
        require(accounts.length <= 100, "Too many at once.");
        ds.initializer.setBlacklistEnabledMultiple(accounts, enabled);
    }
}
