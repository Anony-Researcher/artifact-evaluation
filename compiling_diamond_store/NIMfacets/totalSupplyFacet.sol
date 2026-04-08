/*  
   * SPDX-License-Identifier: MIT

    // Twitter: https://twitter.com/nim_network
    // Website: https://nim.network/
    // Medium:  https://medium.com/@NIM_Network
    // Discord: https://discord.com/invite/nimnetwork

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
