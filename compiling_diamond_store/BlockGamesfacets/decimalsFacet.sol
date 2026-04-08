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
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
