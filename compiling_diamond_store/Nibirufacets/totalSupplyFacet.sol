/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/nibiruchain
    // Twitter: https://twitter.com/NibiruChain
    // Website: https://nibiru.fi/
    // Github: https://github.com/NibiruChain
    // Discord: https://discord.com/invite/nibirufi
    // Medium: https://medium.com/@nibirufi

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
