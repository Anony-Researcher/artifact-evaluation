// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.21;
import "./TestLib.sol";
contract getStrategiesFacet {
    function getStrategies() external view returns (address[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._strategies;
    }
}
