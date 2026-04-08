/**
Welcome to MindAI - $MDAI

Dive into the MindAI era, a groundbreaking platform that redefines the matter of AI. 
MindAI isn't just another AI interface, it's an intelligent, interactive ecosystem directly available via Telegram. 

70+ personalized AI interactions.
ChatGPT 3.5, 4, 4 Turbo.
100% Revenue Share.
Reach up to 200% Staking APY.

Our aim is to create something truly unique
A product that stands apart by providing personalized, AI-driven insights and learning experiences. 
Whether it's navigating the complexities of the cryptocurrency market or exploring new areas like music and art.
MindAI is designed to be your companion in learning and growth.
 
Telegram: https://t.me/MindAIProject
Twitter:  https://x.com/MindAIProject
Website:  http://MindAIProject.com
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
