/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/joineveryworld
    // Twitter: https://twitter.com/JoinEveryworld
    // Website: https://www.everyworld.com/
    // Discord: https://discord.com/invite/everyworld
   
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
