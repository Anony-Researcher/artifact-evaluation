// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://zeusnetwork.xyz/
    Twitter:  https://twitter.com/ZeusNetworkHQ
    Medium:   https://go.zeusnetwork.xyz/zeus-medium
    Discord:  https://discord.com/invite/zeusnetwork

*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
