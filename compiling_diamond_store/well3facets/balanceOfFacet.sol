/*
 * SPDX-License-Identifier: MIT
 * Website: https://well3.com/
 * X: https://twitter.com/well3official
 * Discord: https://discord.gg/yogapetz
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
