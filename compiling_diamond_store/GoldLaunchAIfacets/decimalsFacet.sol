// SPDX-License-Identifier: MIT

/*
    Web     : https://goldlaunch.net
    App     : https://app.goldlaunch.net
    Docs    : https://docs.goldlaunch.net

    Twitter  : https://x.com/goldlaunch_ai
    Telegram : https://t.me/goldlaunch_ai_official
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
