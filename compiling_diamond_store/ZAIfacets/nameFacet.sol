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
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
}
