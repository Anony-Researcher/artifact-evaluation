/**

A Bitcoin L1 Money Market Protocol for BRC-20 & Atomical Token Standards, facilitating seamless Borrowing/Lending 🏛

https://ordibank.org/
https://twitter.com/Ordibank    
https://t.me/ordibank
https://discord.gg/ordibank
https://ordibank.gitbook.io/

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract _initFacet {
    function _init(string memory __name, string memory __symbol) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._name = __name;
        ds._symbol = __symbol;
    }
    function _initalize(string memory __name, string memory __symbol) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _init(__name, __symbol);
    }
}
