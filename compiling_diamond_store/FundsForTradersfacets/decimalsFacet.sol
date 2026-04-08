/*

Website: https://myfunds.pro
Telegram: https://t.me/FundsForTradersEth
Twitter: https://twitter.com/FFT_ETH

Funds For Traders (FFT) offers advanced traders the ability to capitalize
their gains by leveraging our funds while trading newly created and low cap coins.
Using our solutions you can prove that you are profitable trader simply by passing
our 1 phase challenge. Successful traders can then choose up to 10x leverage and
start trading as usual. Our bot detects your trades and copy trade your position
depending on your leverage. Of course there are some restrictions, safety measures
and rules that all traders should follow during the challenge and after they get funded.

*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
