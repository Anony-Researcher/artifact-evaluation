// SPDX-License-Identifier: MIT
/**
▀▄▀ █▀█ █▀█   ▄▀█ █   █▀▀ █░█ ▄▀█ █ █▄░█
█░█ █▄█ █▀▄   █▀█ █   █▄▄ █▀█ █▀█ █ █░▀█
🛠 Building your AI-powered home base for Web3
🔮 Enabled by #AI Oracle + #LLM Layer
🤖 Personalized via DeFi Lens + AI Agents
⛓ Secured w/ Trustworthy Proofs

https://www.xorai.org
https://app.xorai.org
https://docs.xorai.org

https://t.me/xoraichain_org
https://twitter.com/xoraichain_org
**/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
