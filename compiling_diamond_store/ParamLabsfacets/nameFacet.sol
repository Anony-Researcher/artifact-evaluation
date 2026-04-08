/*  
   * SPDX-License-Identifier: MIT

   // Telegram: https://t.me/ethena_labs
    // Twitter: https://twitter.com/paramlaboratory
    // Website: https://paramgaming.com/
    // Discord: https://discord.com/invite/kiraverse
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
