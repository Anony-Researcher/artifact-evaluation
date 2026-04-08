/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/bitbrawl
    // Twitter: https://twitter.com/bitbrawlio
    // Website: https://www.bitbrawl.io/
    // Discord: https://discord.com/invite/bitbrawl
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
