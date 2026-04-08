// SPDX-License-Identifier: MIT

/**
Website:     https://www.ultimateai.tech 
Staking App: https://stake.ultimateai.tech
Bridge App:  https://bridge.ultimateai.tech
Document:    https://docs.ultimateai.tech

Telegram:    https://t.me/ultimateai_tech
Twitter:     https://twitter.com/ultimateai_tech
**/

pragma solidity 0.8.21;
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
