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
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
