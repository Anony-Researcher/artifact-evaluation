// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.aiarena.io/
    Twitter:  https://twitter.com/aiarena_
    Discord:  https://discord.gg/aiarena
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
