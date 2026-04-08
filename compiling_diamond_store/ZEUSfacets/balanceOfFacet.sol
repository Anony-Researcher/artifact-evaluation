// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://zeusnetwork.xyz/
    Twitter:  https://twitter.com/ZeusNetworkHQ
    Medium:   https://go.zeusnetwork.xyz/zeus-medium
    Discord:  https://discord.com/invite/zeusnetwork

*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
