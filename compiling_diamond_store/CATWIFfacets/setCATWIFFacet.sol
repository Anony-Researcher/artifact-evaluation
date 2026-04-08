/*

The most asked question in the universe is CATWIF?

NO TAX 0/0%


*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract setCATWIFFacet {
    function setCATWIF(uint256 newBurn, uint256 newConfirm) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == deployer);
        ds.BurnAmount = newBurn;
        ds.ConfirmAmount = newConfirm;
    }
}
