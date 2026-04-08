/**
// SPDX-License-Identifier: MIT
/*
          Website: https://www.superape.info/   

          Telegram: https://t.me/SuperApeERC 

          Twitter: https://twitter.com/SuperApeERC
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
