// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract getCurrentValueFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function getCurrentValue(
        bytes32 _queryId
    ) public view onlyOwner returns (bytes memory _value) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _value = ds.tellorFlex.getCurrentValue(_queryId);
    }
}
