/*
Unpin Your Data from the Cloud, Pin it to Freedom.

https://d-pinned.com/
https://twitter.com/dpinnedeth
https://t.me/d_pinned
https://docs.d-pinned.com/
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
