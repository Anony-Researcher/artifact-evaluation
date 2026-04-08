/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.scallop.io/
 * Whitepaper: https://docs.scallop.io/
 * Twitter: https://twitter.com/Scallop_io
 * Telegram Group: https://t.me/scallop_io
 * Discord Chat: https://airdrops.io/visit/0ll2/
 * Medium: https://medium.com/scallopio
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
