/**
// SPDX-License-Identifier: MIT
/*
             //https://twitter.com/AndywifhatETH
             //https://t.me/AndywifhatETH
             //https://www.andy-wifhat.com/
             //https://medium.com/@Andywifhat
*/
pragma solidity 0.8.23;
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
