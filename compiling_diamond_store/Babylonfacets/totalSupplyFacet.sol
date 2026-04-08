// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._supply;
    }
}
