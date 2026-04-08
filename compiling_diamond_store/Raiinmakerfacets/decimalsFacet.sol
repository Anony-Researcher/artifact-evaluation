/*  
   * SPDX-License-Identifier: MIT

    //Telegram: https://t.me/raiinmakertalk
    // Twitter: https://twitter.com/raiinmakerapp
    // Website: https://www.raiinmaker.com/
    // Discord: https://discord.com/invite/nxWzdAKCBK
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
