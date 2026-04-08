// SPDX-License-Identifier: UNLICENSE
/*
------------Shelon Musk------------

https://x.com/elonmusk/status/1754919564000035189

The She E O of X

https://t.me/shelonmusk
https://twitter.com/ShelonMuskETH
https://thesheeo.xyz/

*/
pragma solidity 0.8.23;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
