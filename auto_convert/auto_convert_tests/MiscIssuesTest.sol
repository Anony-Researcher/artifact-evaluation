// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract MiscIssuesTest {
    using SafeMath for uint256;
    uint256 private constant _swapThreshold = 1 * 10**18;
    bool private inSwap = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    function test() public lockTheSwap {
        uint256 a = 1;
    }
}