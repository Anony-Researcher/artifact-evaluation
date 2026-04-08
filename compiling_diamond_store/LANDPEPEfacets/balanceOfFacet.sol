/**
 *Submitted for verification at basescan.org on 2024-03-23
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract balanceOfFacet is coffer {
    function balanceOf(address account) public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
