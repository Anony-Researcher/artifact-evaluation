/*  
   * SPDX-License-Identifier: MIT 

    //Telegram: https://t.me/koiinetwork
    // Twitter: https://twitter.com/KoiiFoundation
    // Website: https://www.koii.network/
    // Discord: https://discord.com/invite/koii-network
    
    
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
