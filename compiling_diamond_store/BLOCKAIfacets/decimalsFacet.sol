// SPDX-License-Identifier: UNLICENSE

/*

BLOCK AI is your solution for hassle-free access to Telegram. With our proxies, connecting to Telegram becomes effortless, even in regions with restrictions. BLOCK AI isn't just about accessing Telegram – it's also about empowering you with our very own token. With BlockAI tokens, you gain more than just access; you gain ownership and a stake in our mission.

➡️BLOCK AI Proxies Working: BLOCK AI proxies act as middlemen between your device and Telegram's servers. They hide your real location and keep your identity secure while you browse Telegram.

➡️Why Do We Need BLOCK AI?
In a world of digital restrictions, BLOCK AI breaks barriers. Whether you're avoiding surveillance or simply want to chat freely, BLOCK AI ensures you can connect without limits. 
These proxies are used to bypass internet censorship and access Telegram in regions where it might be blocked or restricted by government authorities or ISPs.

-Telegram: https://t.me/BlockAIErc
-Twitter: https://twitter.com/BuzzAiEth
➡️Website: https://block-ai.cc/
✅Uptime: https://stats.block-ai.cc/
📄 Documentation: https://docs.block-ai.cc
⚡️Bot: @BlockAIProxy_Bot

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
