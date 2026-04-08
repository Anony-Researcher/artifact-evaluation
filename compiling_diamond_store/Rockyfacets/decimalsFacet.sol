/**
// SPDX-License-Identifier: UNLICENSE
/*
     Rocky Boy's Club


   Telegram: https://t.me/Rocky_ETH

   Twitter: https://twitter.com/RockyEth47328

   Website: https://www.rocky-coin.com/


*/
pragma solidity 0.8.21;
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
