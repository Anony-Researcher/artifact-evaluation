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
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
