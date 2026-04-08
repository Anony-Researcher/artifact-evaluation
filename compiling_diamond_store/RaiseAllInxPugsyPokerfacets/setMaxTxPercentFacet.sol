// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract setMaxTxPercentFacet {
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

    function setMaxTxPercent(
        uint256 percent,
        uint256 divisor
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            (_tTotal * percent) / divisor >= ((_tTotal * 5) / 1000),
            "Max Transaction amt must be above 0.5% of total supply."
        );
        ds._maxTxAmount = (_tTotal * percent) / divisor;
    }
}
