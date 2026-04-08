/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/plenafinance
    // Twitter: https://twitter.com/PlenaFinance
    // Website: https://www.plena.finance/
    // Discord: https://discord.com/invite/mSdtPkRfdr
    // Medium:  https://medium.com/@plenafinance
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
