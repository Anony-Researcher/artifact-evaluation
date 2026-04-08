// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract setRatiosFacet {
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

    function setRatios(
        uint16 liquidity,
        uint16 operations,
        uint16 project,
        uint16 marketing
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._ratios.liquidity = liquidity;
        ds._ratios.marketing = marketing;
        ds._ratios.operations = operations;
        ds._ratios.project = project;
        ds._ratios.totalSwap = liquidity + marketing + operations + project;
        uint256 total = ds._taxRates.buyFee + ds._taxRates.sellFee;
        require(
            ds._ratios.totalSwap <= total,
            "Cannot exceed sum of buy and sell fees."
        );
    }
}
