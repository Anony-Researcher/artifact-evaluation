// SPDX-License-Identifier: MIT

/*
    The AI market making money manager - A better way to invest in DeFi.

    Web      : https://magicflowai.trade
    App      : https://app.magicflowai.trade
    Docs     : https://docs.magicflowai.trade

    Twitter  : https://x.com/MagicFlow_AI
    Telegram : https://t.me/magicflow_ai_official
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
