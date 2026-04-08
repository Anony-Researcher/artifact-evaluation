/*  
   * SPDX-License-Identifier: MIT

    // Telegram: https://t.me/zeusnetwork
    // Twitter: https://twitter.com/ZeusNetworkHQ
    // Website: https://zeusnetwork.xyz/
    // Discord: https://discord.com/invite/zeusnetwork
    // Medium:  https://medium.com/@zeus-network
*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
