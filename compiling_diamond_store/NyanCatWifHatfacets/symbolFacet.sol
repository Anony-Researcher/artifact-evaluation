/**
      NyanCatWifHat

   //https://www.nyancat-wifhat.com/
   //https://t.me/NyanCatWifHatETH
   //https://twitter.com/Nyancatwiifhat
   //https://medium.com/@NyanCatWifhat


// SPDX-License-Identifier: UNLICENSE
/*
*/
pragma solidity 0.8.21;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
