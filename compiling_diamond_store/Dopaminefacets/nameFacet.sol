/*  
   * SPDX-License-Identifier: MIT
   
    //Telegram: https://t.me/mydopamineapp
    // Twitter: https://twitter.com/mydopamineapp
    // Website: https://www.dopamineapp.com/
    
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
