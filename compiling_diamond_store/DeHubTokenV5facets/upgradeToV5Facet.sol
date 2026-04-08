pragma solidity ^0.8.3;
import "./TestLib.sol";
contract upgradeToV5Facet is DeHubTokenV4WithVersion {
    modifier lockTheProcess() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inTriggerProcess = true;
        _;
        ds.inTriggerProcess = false;
    }

    function upgradeToV5() external {
        require(version < 5, "DeHubToken: Already upgraded to version 5");
        version = 5;
        console.log("v", version);
    }
}
