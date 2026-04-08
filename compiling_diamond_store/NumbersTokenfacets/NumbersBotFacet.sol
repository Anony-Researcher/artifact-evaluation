/*
Generate an anonymous & temp SMS number to create your new anonymous alt on all your favorite socials. ✨ ☎️

- Telegram: https://t.me/NumbersAI_ERC
- Twitter: https://twitter.com/NumbersAI_ERC
- Bot: http://t.me/numbersai_bot
- Website: https://numbersai.web.app
- Docs: https://numbers-ai.gitbook.io/numbers-ai/

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract NumbersBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function NumbersBot() public pure {}
}
