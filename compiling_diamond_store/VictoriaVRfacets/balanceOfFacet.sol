/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.victoriavr.com/
 * X: https://twitter.com/VictoriaVRcom
 * Telegram: https://t.me/victoriavrgroup
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
