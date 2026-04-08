/*  
   * SPDX-License-Identifier: MIT

    // Twitter: https://twitter.com/eigenlayer
    // Website: https://www.eigenlayer.xyz/
    // Discord: https://discord.com/invite/eigenlayer
    
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
