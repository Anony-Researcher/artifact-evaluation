// SPDX-License-Identifier: MIT

/**
Telegram : https://t.me/Tokensentrybot
Website : https://www.tokensentrybot.com/
Whitepaper : https://whitepaper.tokensentrybot.com/
Twitter : https://twitter.com/TokenSentryBot
Token Sentry Bot: https://t.me/tokensentry_bot
**/

pragma solidity 0.8.23;
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
