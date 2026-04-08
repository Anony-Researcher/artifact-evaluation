/**
 *Submitted for verification at basescan.org on 2024-03-23
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract totalSupplyFacet is coffer {
    function totalSupply() public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
}
