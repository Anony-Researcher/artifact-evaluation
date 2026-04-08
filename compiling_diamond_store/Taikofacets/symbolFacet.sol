/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/taikoxyz
    // Twitter: https://twitter.com/taikoxyz/
    // Website: https://taiko.xyz/
    // Medium:  https://medium.com/taikoxyz
    // Discord:  https://discord.com/invite/taikoxyz

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
