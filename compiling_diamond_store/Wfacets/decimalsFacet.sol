/*
 * SPDX-License-Identifier: MIT
 * Website: https://wormholenetwork.com/
 * Whitepaper: https://github.com/
 * Twitter: https://twitter.com/wormhole
 * Telegram: https://t.me/wormholecrypto
 * Discord Chat: https://discord.gg/xsT8qrHAvV
 * Medium: https://wormholecrypto.medium.com/
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
