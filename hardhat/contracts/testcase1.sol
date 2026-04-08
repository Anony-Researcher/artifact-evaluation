// Test Case 1: Small Normal Contract with Primitive Data Types
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract SmallNormalPrimitive {
    uint storedData;

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint) {
        return storedData;
    }
}

