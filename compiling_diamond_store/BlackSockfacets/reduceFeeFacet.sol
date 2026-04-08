/**
// SPDX-License-Identifier: UNLICENSE

------------BlackSock Capital------------


https://t.me/blacksockcapital
https://blacksockcapital.xyz/
https://twitter.com/BlackSockETH
https://x.com/elonmusk/status/1544374564255309826?s=20

Because Socks simply outperform Rocks


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
