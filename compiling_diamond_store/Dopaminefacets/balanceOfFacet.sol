/*  
   * SPDX-License-Identifier: MIT
   
    //Telegram: https://t.me/mydopamineapp
    // Twitter: https://twitter.com/mydopamineapp
    // Website: https://www.dopamineapp.com/
    
 
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
