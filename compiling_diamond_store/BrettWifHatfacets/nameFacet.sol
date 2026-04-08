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
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
