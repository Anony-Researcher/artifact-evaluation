/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.affi.network/
 * Whitepaper: https://www.affi.network/docs/welcome/
 * Twitter: https://twitter.com/affi_network
 * Telegram Group: https://t.me/AffiNetworkOfficial
 * Discord Chat: https://discord.gg/3Tc3p5eBv5
 * Github: https://github.com/affinetwork
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
