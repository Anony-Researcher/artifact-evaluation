/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/BeFiLabsAnn
    // Twitter: https://twitter.com/BefiLabs
    // Website: https://befilabs.com/
    // Discord: https://discord.com/invite/asvrdMp9e8
    // Medium:  https://befilabs.medium.com/
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
