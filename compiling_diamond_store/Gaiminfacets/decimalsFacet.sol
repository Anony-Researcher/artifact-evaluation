/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/officialgaimin
    // Twitter: https://twitter.com/GaiminIo
    // Website: https://www.gaimin.io/
    // Discord: https://discord.com/invite/jemqJ9PkCJ
    // Medium:  https://gaimin.medium.com/
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
