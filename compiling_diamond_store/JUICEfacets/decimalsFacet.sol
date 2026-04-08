/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.juice.finance/
 * Whitepaper: https://juice-finance.gitbook.io/juice-finance
 * Twitter: https://twitter.com/Juice_Finance
 * Telegram Group: https://t.me/Juice_Finance
 * Discord Chat: https://discord.gg/juicefinance
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
