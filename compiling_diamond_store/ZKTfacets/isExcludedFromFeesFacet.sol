/**
 *Submitted for verification at Etherscan.io on 2024-03-05
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
