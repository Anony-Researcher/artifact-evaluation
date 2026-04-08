// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./TestLib.sol";
contract syncPairFacet is Ownable {
    modifier onlyMaster() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.master);
        _;
    }

    function syncPair() external onlyMaster {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._pair.sync();
    }
}
