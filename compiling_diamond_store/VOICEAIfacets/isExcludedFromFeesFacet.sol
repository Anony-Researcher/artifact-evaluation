/*

Voice AI is an advanced Telegram AI bot enabling you to create audio notes from text
,employing voices of celebrities. Additionally, you will be able to create your own
customized voices and use them as you wish.

WEBSITE:       https://ethvoiceai.xyz/
TELEGRAM:      https://t.me/voiceai_eth
TG BOT:        https://t.me/ethvoiceai_bot
TWITTER:       https://twitter.com/voiceai_eth
DOCS:          https://voice-ai.gitbook.io/voice-ai

*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
