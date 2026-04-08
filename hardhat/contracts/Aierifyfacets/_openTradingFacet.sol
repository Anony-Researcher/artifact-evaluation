/**

    Website: https://aierify.io
    Telegram: https://t.me/aierify
    Twitter:  https://x.com/aierify


**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract _openTradingFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event TradingActive(bool _tradingOpen, bool _swapEnabled);
    function _openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
        emit TradingActive(ds.tradingOpen, ds.swapEnabled);
    }
}
