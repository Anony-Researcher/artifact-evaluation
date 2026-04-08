/*  
   * SPDX-License-Identifier: MIT 

    Website:  https://debridge.finance/
    Twitter:  https://twitter.com/deBridgeFinance
    Telegram: https://t.me/deBridge_finance
    Discord: https://discord.com/invite/debridge


*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
