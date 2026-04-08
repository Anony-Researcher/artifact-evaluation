// SPDX-License-Identifier: MIT

/*
    Web     : https://optimalai.dev
    App     : https://app.optimalai.dev
    Doc     : https://docs.optimalai.dev

    Twitter : https://twitter.com/optimalaipro
    Telegram: https://t.me/optimalaiprotocol
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
