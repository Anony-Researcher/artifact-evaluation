/*  
   * SPDX-License-Identifier: MIT

    // Twitter: https://twitter.com/eigenlayer
    // Website: https://www.eigenlayer.xyz/
    // Discord: https://discord.com/invite/eigenlayer
    
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
