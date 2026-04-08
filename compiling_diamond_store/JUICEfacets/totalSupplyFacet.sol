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
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
