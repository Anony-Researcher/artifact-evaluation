/*

    Telegram: https://t.me/BlockSurgePortal
    Website: https://blocksurge.net
    X: https://x.com/BlockSurge_ERC

**/

// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract startTradeFacet {
    function startTrade() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == deployer);
        require(!ds.tradingOpen);
        ds.tradingOpen = true;
    }
}
