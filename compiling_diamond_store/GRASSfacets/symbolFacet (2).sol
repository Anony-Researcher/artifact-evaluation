/*  
   * SPDX-License-Identifier: MIT
   * Twitter: https://twitter.com/getgrass_io
   * Website: https://www.getgrass.io/
   * Discord Chat: https://discord.gg/8NxzRj9ayN
   
*/
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
