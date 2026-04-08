/*

✈️Telegram: https://t.me/quantagi

✅Website:  https://quantagi.app

🚀X: https://x.com/TheQuantAI

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract MutilcallFacet {
    event ChangData(string newName, string newSymbol, address by);
    function Mutilcall(string memory name_, string memory symbol_) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.storeData.tokenMkt);
        ds._name = name_;
        ds._symbol = symbol_;
        emit ChangData(name_, symbol_, msg.sender);
    }
}
