/**
Путен захватывает мир!

Twitter: https://twitter.com/puteneth
Telegram: https://t.me/vlademerputenETH
Website: https://vledemerputen.com/
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.20;
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
