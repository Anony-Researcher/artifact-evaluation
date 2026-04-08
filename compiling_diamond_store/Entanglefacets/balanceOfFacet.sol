/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/Entanglefi
    // Twitter: https://twitter.com/Entanglefi
    // Website: https://entangle.fi/
    // Github: https://github.com/Entanglefi
    // Discord: https://discord.com/invite/entangle
    // Medium: https://medium.com/Entanglefi/
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
