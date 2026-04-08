/**
// SPDX-License-Identifier: UNLICENSE

------------Wide Putin Meme------------

Vladimir putin is reelected as the "widest" president of russia 2024

https://t.me/wideputinETH

https://wideputineth.com/

https://twitter.com/wideputinETH

---------------------------------------
Powered by https://t.me/FairLaunchDev
---------------------------------------
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
