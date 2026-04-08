/*
 * SPDX-License-Identifier: MIT
 * Website: https://ritual.net/
 * X: https://twitter.com/ritualnet
 * Discord: https://discord.com/invite/ritual-net
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
