/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/bitbrawl
    // Twitter: https://twitter.com/bitbrawlio
    // Website: https://www.bitbrawl.io/
    // Discord: https://discord.com/invite/bitbrawl
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
