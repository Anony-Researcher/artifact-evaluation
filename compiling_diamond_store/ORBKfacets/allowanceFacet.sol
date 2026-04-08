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
contract allowanceFacet {
    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
}
