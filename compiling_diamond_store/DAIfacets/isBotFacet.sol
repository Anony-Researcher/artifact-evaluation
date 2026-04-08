/*
DelusionAI - revolutionizes art creation, transforming typed prompts into unique images and mintable NFTs.
Website:    https://delusionai.io
Telegram:   https://t.me/DelusionAIPortal
Twitter:    https://twitter.com/DelusionAIToken
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
