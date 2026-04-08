/*
 * SPDX-License-Identifier: MIT
 * Website: https://elys.network/
 * Whitepaper: https://elys-network.gitbook.io/docs
 * Twitter: https://twitter.com/elys_network
 * Telegram: https://t.me/elysnetwork
 * Discord Chat: https://discord.gg/elysnetwork
 * Medium: https://elysnetwork.medium.com/
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
