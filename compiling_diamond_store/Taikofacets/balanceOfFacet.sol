/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/taikoxyz
    // Twitter: https://twitter.com/taikoxyz/
    // Website: https://taiko.xyz/
    // Medium:  https://medium.com/taikoxyz
    // Discord:  https://discord.com/invite/taikoxyz

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
