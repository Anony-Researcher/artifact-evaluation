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
contract transferFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address recipient, uint256 amount) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._balances[msg.sender] -= amount;
        ds._balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
}
