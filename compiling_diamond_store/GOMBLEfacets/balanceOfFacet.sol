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
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
