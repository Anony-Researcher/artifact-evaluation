/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.saga.xyz/?utm_source=icodrops
 * Whitepaper:https://www.saga.xyz/#litepaper
 * Twitter: https://twitter.com/Sagaxyz__
 * Telegram: https://t.me/sagaofficialchannel
 * Reddit: https://www.reddit.com/r/saga_xyz/
 * Discord: https://discord.gg/uHh8gfc56b
 * Youtube: https://www.youtube.com/channel/UC_DT-9dwPL6XMG9iT0BkAmg
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
