//Telegram: https://t.me/bmogcoin

//Twitter: https://twitter.com/babymogcoineth

//Website: https://babymog.vip

// SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.23;
import "./TestLib.sol";
contract LowerMaximumTaxFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function LowerMaximumTax(uint256 _newFee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
}
