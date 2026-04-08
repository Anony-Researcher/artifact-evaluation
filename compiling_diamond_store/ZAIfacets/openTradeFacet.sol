/**

THE VANGUARD OF AI BOTS.

Website: https://zaibot.io/
Twitter: https://x.com/zaibotio/      
Public Chat: https://t.me/zaibotpublic
Announcement channel: https://t.me/zaibotann

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract openTradeFacet {
    function openTrade(address __pair) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        ds._pair = __pair;
    }
}
