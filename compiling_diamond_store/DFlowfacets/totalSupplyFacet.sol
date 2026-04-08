/*  
   * SPDX-License-Identifier: MIT 

    //Telegram: https://t.me/DFlowProtocol
    // Twitter: https://twitter.com/DFlowProtocol
    // Website: https://dflow.net/
    // Discord: https://discord.com/invite/dflow
    
    
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
