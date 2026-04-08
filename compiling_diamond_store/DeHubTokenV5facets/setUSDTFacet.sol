pragma solidity ^0.8.3;
import "./TestLib.sol";
contract setUSDTFacet is DeHubTokenV4WithVersion {
    modifier lockTheProcess() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inTriggerProcess = true;
        _;
        ds.inTriggerProcess = false;
    }

    function setUSDT(address USDT_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.USDT = USDT_;
    }
}
