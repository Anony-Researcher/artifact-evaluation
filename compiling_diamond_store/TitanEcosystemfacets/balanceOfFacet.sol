/**
 *Submitted for verification at Etherscan.io on 2023-10-31
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract balanceOfFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
