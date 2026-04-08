// SPDX-License-Identifier: UNLICENSE
/*
------------Shelon Musk------------

https://x.com/elonmusk/status/1754919564000035189

The She E O of X

https://t.me/shelonmusk
https://twitter.com/ShelonMuskETH
https://thesheeo.xyz/

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
