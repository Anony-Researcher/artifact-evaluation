/**
// SPDX-License-Identifier: UNLICENSE

#SuperBabyInuTrumpAIPepeCorgiCatWifHat will be the new niche in the memecoin genre on CoinMarketCap
https://x.com/davidsalamon/status/1768229631289852057?s=20


https://t.me/TheTickerIsCMC
https://twitter.com/TheTickerIsCMC
https://superbabyinutrumpaipepecorgicatwifhat.xyz/


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
