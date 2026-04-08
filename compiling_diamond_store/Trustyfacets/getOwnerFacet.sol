// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract getOwnerFacet {
    function getOwner() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.owner;
    }
}
