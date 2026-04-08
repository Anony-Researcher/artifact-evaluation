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
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
