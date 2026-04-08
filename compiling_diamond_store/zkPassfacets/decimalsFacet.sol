/*  
   * SPDX-License-Identifier: MIT

    // Twitter: https://twitter.com/zkPass
    // Website: https://zkpass.org/
    // Discord: https://discord.com/invite/zkpass
    // Medium:  https://medium.com/zkpass

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
