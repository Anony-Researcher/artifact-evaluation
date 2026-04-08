/*  
   * SPDX-License-Identifier: MIT


     // Telegram: https://t.me/+afYqz2KG_YNlNzNl
    // Twitter: https://twitter.com/Stake_Stone
    // Website: https://stakestone.io/
    // Discord: https://discord.com/invite/jemqJ9PkCJ
    // Medium:  https://medium.com/@official_42951


*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
