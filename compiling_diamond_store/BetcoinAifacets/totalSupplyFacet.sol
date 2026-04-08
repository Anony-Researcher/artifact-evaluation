/*
WEBSITE https://thebetcoin.app
TWITTER https://twitter.com/Betcoineth
TELEGRAM https://t.me/BetcoinAiETH
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tTotal;
    }
}
