// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract setEscrowFacet {
    function setEscrow(address newESCROW) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.ESCROW = newESCROW;
    }
    function setRevenue(address newREVENUE) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.REVENUE = newREVENUE;
    }
    function getRevenue() external view onlyOwner returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.REVENUE;
    }
}
