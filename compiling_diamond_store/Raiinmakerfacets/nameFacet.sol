/*  
   * SPDX-License-Identifier: MIT

    //Telegram: https://t.me/raiinmakertalk
    // Twitter: https://twitter.com/raiinmakerapp
    // Website: https://www.raiinmaker.com/
    // Discord: https://discord.com/invite/nxWzdAKCBK
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
