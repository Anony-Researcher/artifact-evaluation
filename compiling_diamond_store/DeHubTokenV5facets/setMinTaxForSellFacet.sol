pragma solidity ^0.8.3;
import "./TestLib.sol";
contract setMinTaxForSellFacet is DeHubTokenV4WithVersion {
    modifier lockTheProcess() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inTriggerProcess = true;
        _;
        ds.inTriggerProcess = false;
    }

    event SetMinTaxForSell(uint256 minTaxForSell);
    function setMinTaxForSell(uint256 minTaxForSell_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.minTaxForSell != minTaxForSell_);
        ds.minTaxForSell = minTaxForSell_;
        emit SetMinTaxForSell(minTaxForSell_);
    }
}
