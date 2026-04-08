// SPDX-License-Identifier: UNLICENSE

/*

SpeysX - $SPEYSX

hop in teh rockot, we gewn to teh mewn and mors with SpeysX 🚀

🌐 websoit: https://SpeysX.co/
❌ x: https://x.com/SpeysXETH
✉️ tg: https://t.me/SpeysXETH

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
