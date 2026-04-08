// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract isExcludedFacet {
    function isExcluded(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcluded[account];
    }
}
