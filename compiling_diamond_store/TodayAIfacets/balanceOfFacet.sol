/**

*/

/*  
   * SPDX-License-Identifier: MIT

    // Twitter: https://twitter.com/todaythegame
    // Website: https://side.xyz/today / https://www.todaythegame.com/
    // Discord: https://discord.com/invite/todaythegame
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
