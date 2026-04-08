/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://discord.com/invite/cellulalifegame
    // Twitter: https://twitter.com/cellulalifegame
    // Website: https://www.cellula.life/
    // Discord: https://discord.com/invite/2PMU2NvDcm
    // Medium:  https://cellula.medium.com/
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
