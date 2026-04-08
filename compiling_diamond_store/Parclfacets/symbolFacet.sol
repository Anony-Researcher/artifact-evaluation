/*  
   * SPDX-License-Identifier: MIT

    // Twitter: https://twitter.com/Parcl
    // Website: https://www.parcl.co/
    // Discord: https://discord.com/invite/parcl
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
