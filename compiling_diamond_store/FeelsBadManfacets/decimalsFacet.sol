/**
// SPDX-License-Identifier: UNLICENSE
/*
             Feels Bad Man - Enemy Feels Good Man

        - https://twitter.com/FeelsBadManETH
        - https://medium.com/@FeelsBadMan
        - https://t.me/FeelsBadManETH
        - https://www.feels-badman.com/

*/
pragma solidity 0.8.24;
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
