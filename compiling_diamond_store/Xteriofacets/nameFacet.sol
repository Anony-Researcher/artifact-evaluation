/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://xter.io
    ▫️Twitter: https://twitter.com/XterioGames
    ▫️Discord: https://discord.gg/xteriogames
    ▫️Medium: https://medium.com/@XterioGames
*/
pragma solidity ^0.8.15;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
