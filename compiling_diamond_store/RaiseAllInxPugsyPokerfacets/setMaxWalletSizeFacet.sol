// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract setMaxWalletSizeFacet {
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

    function setMaxWalletSize(
        uint256 percent,
        uint256 divisor
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            (_tTotal * percent) / divisor >= (_tTotal / 100),
            "Max Wallet amt must be above 1% of total supply."
        );
        ds._maxWalletSize = (_tTotal * percent) / divisor;
    }
}
