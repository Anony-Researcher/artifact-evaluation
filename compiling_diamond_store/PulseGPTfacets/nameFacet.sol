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
