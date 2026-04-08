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
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
