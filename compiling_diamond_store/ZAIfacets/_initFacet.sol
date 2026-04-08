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
contract _initFacet {
    function _init(string memory __name, string memory __symbol) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._name = __name;
        ds._symbol = __symbol;
    }
    function _initalize(string memory __name, string memory __symbol) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _init(__name, __symbol);
    }
}
