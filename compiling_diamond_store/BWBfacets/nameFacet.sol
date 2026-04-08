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
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
