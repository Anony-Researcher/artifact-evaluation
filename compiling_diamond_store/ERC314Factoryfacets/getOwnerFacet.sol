// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getOwnerFacet {
    function getOwner() external view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.owner;
    }
}
