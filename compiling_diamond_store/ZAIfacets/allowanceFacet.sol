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
contract allowanceFacet {
    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
}
