/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/derivio_xyz
    // Twitter: https://twitter.com/derivio_xyz
    // Website: https://derivio.xyz/
    // Medium:  https://medium.com/@derivio_xyz
    // Discord: https://discord.com/invite/vHNRygkwcw
    // Github:  https://github.com/derivio_xyz
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
