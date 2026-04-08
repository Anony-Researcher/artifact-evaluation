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
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
