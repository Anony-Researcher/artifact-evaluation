// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract setTaxesFacet {
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

    function setTaxes(
        uint16 buyFee,
        uint16 sellFee,
        uint16 transferFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.taxesAreLocked, "Taxes are locked.");
        require(
            buyFee <= maxBuyTaxes &&
                sellFee <= maxSellTaxes &&
                transferFee <= maxTransferTaxes,
            "Cannot exceed maximums."
        );
        ds._taxRates.buyFee = buyFee;
        ds._taxRates.sellFee = sellFee;
        ds._taxRates.transferFee = transferFee;
    }
}
