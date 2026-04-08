// SPDX-License-Identifier: MIT

/*
    Web      : https://synthesis.money
    Doc      : https://docs.synthesis.money

    Twitter  : https://twitter.com/synthesisaifin
    Telegram : https://t.me/synthesisai_official
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
