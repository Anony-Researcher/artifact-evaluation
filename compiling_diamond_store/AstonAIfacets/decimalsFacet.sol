// SPDX-License-Identifier: MIT

/*
    Web      : https://astonai.space
    App      : https://app.astonai.space
    Doc      : https://docs.astonai.space

    Twitter  : https://twitter.com/astonailab
    Telegram : https://t.me/AstonAILab
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
