// SPDX-License-Identifier: Unlicensed

/**
https://pepebtc.tech/
https://t.me/PepeBitcoinPortal
https://twitter.com/PepeBitcoin_
**/

pragma solidity ^0.8.18;
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
