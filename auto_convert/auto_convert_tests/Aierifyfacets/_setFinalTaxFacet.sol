/**

    Website: https://aierify.io
    Telegram: https://t.me/aierify
    Twitter:  https://x.com/aierify


**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract _setFinalTaxFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event FinalTax(uint256 _valueBuy, uint256 _valueSell);
    function _setFinalTax(
        uint256 _valueBuy,
        uint256 _valueSell
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _valueBuy <= 30 && _valueSell <= 30 && ds.tradingOpen,
            "Exceeds value"
        );
        ds._finalBuyTax = _valueBuy;
        ds._finalSellTax = _valueSell;
        emit FinalTax(_valueBuy, _valueSell);
    }
}
