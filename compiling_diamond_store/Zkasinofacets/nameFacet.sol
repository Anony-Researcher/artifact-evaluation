/**
 *Submitted for verification at Etherscan.io on 2024-03-18
 */

/*  
   * SPDX-License-Identifier: MIT

      // Telegram: https://t.me/ZKasino
    // Twitter: https://twitter.com/ZKasino_io
    // Website: https://zkasino.io/
    // Discord: https://discord.com/invite/zkasino
    // Medium:  https://zkasino.medium.com/
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
