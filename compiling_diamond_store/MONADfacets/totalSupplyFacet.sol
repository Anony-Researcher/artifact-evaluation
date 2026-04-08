// SPDX-License-Identifier: UNLICENSED
// Website: https://www.monad.xyz
// Twitter: https://twitter.com/monad_xyz
// Discord: https://discord.com/invite/monad
// Telegram: https://t.me/monad_xyz

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
