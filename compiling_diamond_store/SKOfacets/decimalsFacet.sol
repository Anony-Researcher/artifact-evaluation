// SPDX-License-Identifier: MIT

/*
    Website: https://www.sugarkingdom.io/
    Twitter: https://twitter.com/SugarKingdomNFT
    Discord: https://discord.com/invite/sugar-kingdom
    Sugar Kingdom is a gaming platform in which projects from all chains can bring direct utility to their token, and a place in which users can do 100Xs while using their favorite low-caps.
*/

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
}
