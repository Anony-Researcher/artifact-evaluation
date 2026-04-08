/**
 *Submitted for verification at Etherscan.io on 2024-03-23
 */

// SPDX-License-Identifier: MIT
//Telegram: fuck your mom gasless dev
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract allowanceFacet {
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.a[owner][spender];
    }
}
