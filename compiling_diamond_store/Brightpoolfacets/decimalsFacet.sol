/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/brightpoolfinance
    // Twitter: https://twitter.com/BrightpoolX
    // Website: https://brightpool.finance/
    // Discord: https://discord.com/invite/Up84GAStR2
    // Medium:  https://medium.com/@Brightpool.finance
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
