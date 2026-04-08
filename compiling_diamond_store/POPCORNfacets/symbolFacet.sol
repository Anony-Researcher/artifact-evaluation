/*
Invest into the web entertainment market using $POPCORN.

Invest & Analyze the ROI of Youtube Channels using Popcorn AI

Website: https://popcornassets.com/
Telegram Portal: https://t.me/popcornassets
dApp: https://dapp.popcornassets.com/
Twitter: https://twitter.com/PopcornAssets

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
