/*  
   * SPDX-License-Identifier: MIT 

    //Telegram: https://t.me/koiinetwork
    // Twitter: https://twitter.com/KoiiFoundation
    // Website: https://www.koii.network/
    // Discord: https://discord.com/invite/koii-network
    
    
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
