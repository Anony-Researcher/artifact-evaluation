/*  
   * SPDX-License-Identifier: MIT

    // Twitter: https://twitter.com/Parcl
    // Website: https://www.parcl.co/
    // Discord: https://discord.com/invite/parcl
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
