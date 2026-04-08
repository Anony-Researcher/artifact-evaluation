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
contract totalSupplyFacet {
    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }
}
