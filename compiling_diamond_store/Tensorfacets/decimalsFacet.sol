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
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
