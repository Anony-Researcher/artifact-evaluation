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
contract reduceFeeFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function reduceFee(uint256 _newFee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
}
