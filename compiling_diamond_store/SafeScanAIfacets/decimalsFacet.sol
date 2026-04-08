//SPDX-License-Identifier: UNLICENSED

/*
 * Telegram: https://t.me/safescanai
 * Twitter: https://twitter.com/SafeScanAI
 * Website: https://safescanai.com/
 * Dapp: https://app.safescanai.com/
 * Docs: https://safe-scan-ai.gitbook.io/
 */

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }
}
