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
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
