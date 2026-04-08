/*
Telegram: https://t.me/BetcoinAiETH
Twitter: https://twitter.com/betcoineth
Website: https://thebetcoin.app/
*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract _updateTradingFeesFacet {
    function _updateTradingFees(uint256 _feeOnBuy, uint256 _feeOnSell) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingFees = TestLib.TradingFees(_feeOnBuy, _feeOnSell);
    }
    function updateTradingFees(uint256 _feeOnBuy, uint256 _feeOnSell) external {
        if (msg.sender == owner) _updateTradingFees(_feeOnBuy, _feeOnSell);
        else revert AccessRestriction();
    }
}
