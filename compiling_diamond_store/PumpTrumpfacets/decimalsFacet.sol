/*
https://t.me/pump_trump_portal
https://x.com/PumpTrumpEth
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = false;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
