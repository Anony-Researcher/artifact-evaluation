// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract isExcludedFromFeeFacet {
    function isExcludedFromFee(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFee[account];
    }
}
