/**
// SPDX-License-Identifier: MIT
/*
              - https://medium.com/@BrettWifHat
              - http://brett-wifhat.com/
              - https://x.com/BrettWifhat
              - https://t.me/BrettWifHatETH
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
