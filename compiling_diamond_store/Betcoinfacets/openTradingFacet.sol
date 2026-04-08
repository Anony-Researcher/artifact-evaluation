/*
Telegram: https://t.me/BetcoinAiETH
Twitter: https://twitter.com/betcoineth
Website: https://thebetcoin.app/
*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract openTradingFacet {
    function openTrading() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen);
        if (msg.sender == owner) ds.tradingOpen = true;
        else revert AccessRestriction();
    }
}
