// SPDX-License-Identifier: MIT

/*
    Website  : https://synthesis.bond
    Docs     : https://docs.synthesis.bond

    Twitter  : https://twitter.com/synthesisbond
    Telegram : https://t.me/synthesisbond
*/

pragma solidity 0.8.19;
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
