/**
    
    Ophel AI is more than just an AI content generator, 
    We're building a vibrant community where creators connect and thrive,
    all powered by our cryptocurrency ecosystem 

    Dapp          : https://staking.ophel.org/
    Website       : https://ophel.org/
    Telegram      : https://t.me/ophel_AI
    Telegram bot  : https://t.me/ophelai_bot
    X             : https://twitter.com/OphelAIOfficial
    Discord       : https://discord.gg/FxW6MVr5
    Docs          : https://docs.ophel.org/
    
**/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
