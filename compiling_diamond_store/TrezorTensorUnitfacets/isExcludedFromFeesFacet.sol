/*
Your gateway to innovation. Rent nodes effortlessly, harness TPU services, and explore the frontiers of Artificial Intelligence.

 https://trezorcomputing.io
 https://app.trezorcomputing.io
 https://t.me/trezorcomputing
 https://twitter.com/TrezorComputing
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
