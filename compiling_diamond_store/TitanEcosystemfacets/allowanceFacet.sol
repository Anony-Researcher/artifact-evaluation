/**
 *Submitted for verification at Etherscan.io on 2023-10-31
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract allowanceFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        _;
    }

    function allowance(
        address account,
        address spender
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[account][spender];
    }
}
