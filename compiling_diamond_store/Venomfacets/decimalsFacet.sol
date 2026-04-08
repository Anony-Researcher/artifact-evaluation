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
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
