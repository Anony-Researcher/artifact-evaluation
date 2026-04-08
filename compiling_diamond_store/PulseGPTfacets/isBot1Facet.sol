// SPDX-License-Identifier: UNLICENSE

/*

Pulse GPT 

Pulse GPT- your AI assistant for all your task.
This is an intelligent AI chat that learns on its own and can help with projects of any complexity.

Project Links:
🌐Website: https://pulsegpt.site/
❌Twitter: https://twitter.com/pulsegpt_eth
✉️Telegram: https://t.me/pulsegpt_portal


*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract isBot1Facet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot1(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
