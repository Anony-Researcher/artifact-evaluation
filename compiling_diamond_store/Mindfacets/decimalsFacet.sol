/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/MindNetwork_xyz
    // Twitter: https://twitter.com/mindnetwork_xyz
    // Website: https://mindnetwork.xyz/
    // Discord: https://discord.com/invite/UYj94MJdGJ
    // Medium:  https://mindnetwork.medium.com/

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
