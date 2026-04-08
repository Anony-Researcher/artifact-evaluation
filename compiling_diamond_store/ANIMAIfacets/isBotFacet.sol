// SPDX-License-Identifier: UNLICENSE

/*
AI Web3 Community Token Brainpup of GPT4.

Website: https://www.animai.tech
Telegram: https://t.me/animai_erc 
Twitter: https://twitter.com/AnimAI_eth
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
