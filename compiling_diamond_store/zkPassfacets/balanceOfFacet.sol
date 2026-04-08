/*  
   * SPDX-License-Identifier: MIT

    // Twitter: https://twitter.com/zkPass
    // Website: https://zkpass.org/
    // Discord: https://discord.com/invite/zkpass
    // Medium:  https://medium.com/zkpass

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
