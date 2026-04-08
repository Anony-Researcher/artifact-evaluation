// SPDX-License-Identifier: UNLICENSED
// Website: https://www.monad.xyz
// Twitter: https://twitter.com/monad_xyz
// Discord: https://discord.com/invite/monad
// Telegram: https://t.me/monad_xyz

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
