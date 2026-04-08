/*
Website: https://p3p3.world
Telegram: https://t.me/OfficialP3P3
Twitter: https://twitter.com/OfficialP3P3

Tokenomics:

Name: P3P3
Symbol: $P3P3
Supply: 420.690.000.000.000
2% Max Wallet & Trx
0% Tax on Buy & Sell
*/
pragma solidity ^0.8.17;
import "./TestLib.sol";
contract shouldTakeFeeFacet is Ownable {
    using SafeMath for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return !ds.isFeeExempt[sender];
    }
}
