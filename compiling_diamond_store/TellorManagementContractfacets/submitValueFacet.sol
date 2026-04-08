// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract submitValueFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function submitValue(
        bytes32 queryId,
        bytes calldata price,
        uint256 nonce,
        bytes calldata queryData
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 timeOfLastNewValue = ds.tellorFlex.getTimeOfLastNewValue();
        uint256 offset = block.timestamp - timeOfLastNewValue;
        require(offset > 60, "too close");
        ds.tellorFlex.submitValue(queryId, price, nonce, queryData);
    }
    function mintAndSubmit(
        bytes32 queryId,
        bytes calldata price,
        uint256 nonce,
        bytes calldata queryData
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 timeOfLastNewValue = ds.tellorFlex.getTimeOfLastNewValue();
        uint256 offset = block.timestamp - timeOfLastNewValue;
        require(offset > 60, "too close");
        ds.tellorToken.mintToOracle();
        ds.tellorFlex.submitValue(queryId, price, nonce, queryData);
    }
    function mintToOracle() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tellorToken.mintToOracle();
    }
}
