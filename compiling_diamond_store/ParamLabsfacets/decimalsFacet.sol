/*  
   * SPDX-License-Identifier: MIT

   // Telegram: https://t.me/ethena_labs
    // Twitter: https://twitter.com/paramlaboratory
    // Website: https://paramgaming.com/
    // Discord: https://discord.com/invite/kiraverse
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
