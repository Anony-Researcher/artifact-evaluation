/*
SociumAI: redefines chatbot creation! 
Build your own intelligent chatbot in under 5 minutes, all without writing a single line of code.

Website: https://sociumai.org/
Whitepaper: https://docs.sociumai.org/
Twitter: https://twitter.com/Socium_AI
Telegram Portal: https://t.me/sociumai
Create your own ChatBot: https://t.me/sociumai_bot

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
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
