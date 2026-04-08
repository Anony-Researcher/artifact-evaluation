/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/paramgaming
    // Twitter: https://twitter.com/paramlaboratory
    // Website: https://paramgaming.com/
    // Discord: https://discord.com/invite/kiraverse
    // Medium:  https://paramgaming.medium.com/
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
