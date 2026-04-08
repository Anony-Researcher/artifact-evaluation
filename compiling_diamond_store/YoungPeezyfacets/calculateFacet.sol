// SPDX-License-Identifier: Unlicensed

/**
        TG: https://t.me/Young_peezy
        
    **/

pragma solidity 0.8.20;
import "./TestLib.sol";
contract calculateFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function calculate(
        uint256 amount,
        uint256 bps
    ) public pure returns (uint256) {
        uint256 bpz = bps * 100;
        return (amount * bpz) / 10_000;
    }
}
