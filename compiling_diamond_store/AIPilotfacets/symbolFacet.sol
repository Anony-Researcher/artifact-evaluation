// SPDX-License-Identifier: MIT

/**
    Web     : https://aipilot.money
    App     : https://app.aipilot.money
    Doc     : https://docs.aipilot.money

    Twitter : https://twitter.com/aipilotreactor
    Telegram: https://t.me/aipilot_official

*/
pragma solidity 0.8.19;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
