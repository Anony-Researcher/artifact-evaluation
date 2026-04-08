// SPDX-License-Identifier: MIT

/**

Train, Learn and Earn with AI-Solutions from Global Crowd.

Website: https://www.intelverseai.com
Telegram: https://t.me/IntelVerseAI
Twitter: https://twitter.com/intelverseAI
Dapp: https://app.intelverseai.com

**/

pragma solidity 0.8.21;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLock = true;
        _;
        ds.inSwapLock = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
