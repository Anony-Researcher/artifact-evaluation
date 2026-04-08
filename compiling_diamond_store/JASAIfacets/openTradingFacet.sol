/*

The most asked question in the universe is JASAI?

NO TAX 0/0%


*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract openTradingFacet {
    function openTrading() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == deployer);
        require(!ds.tradingOpen);
        ds.tradingOpen = true;
    }
}
