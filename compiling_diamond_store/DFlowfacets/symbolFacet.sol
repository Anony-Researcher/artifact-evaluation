/*  
   * SPDX-License-Identifier: MIT 

    //Telegram: https://t.me/DFlowProtocol
    // Twitter: https://twitter.com/DFlowProtocol
    // Website: https://dflow.net/
    // Discord: https://discord.com/invite/dflow
    
    
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
