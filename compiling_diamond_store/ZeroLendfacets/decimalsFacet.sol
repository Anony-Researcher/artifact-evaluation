/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/zerolendxyz
    // Twitter: https://twitter.com/zerolendxyz
    // Website: https://zerolend.xyz/
    // Discord: https://discord.com/invite/zerolend
    // Medium:  https://zerolend.medium.com/
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
