/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/aevoxyz
    // Twitter: https://twitter.com/aevoxyz
    // Website: https://www.aevo.xyz/
    // Medium:  https://medium.com/@aevoxyz
    // Discord: https://discord.com/invite/aevo
    // Github:  https://github.com/aevoxyz
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
