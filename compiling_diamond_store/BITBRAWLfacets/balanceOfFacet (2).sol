/*
 * SPDX-License-Identifier: MIT
 * Website: https://bitbrawl.io
 * X: https://twitter.com/bitbrawlio
 * Telegram: https://t.me/BitbrawlGlobal
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
