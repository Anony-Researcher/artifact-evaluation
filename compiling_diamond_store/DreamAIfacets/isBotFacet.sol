/*
Dream - AI Art Generator is an art station for you. You can turn text into any image or photo you want. It's like magic: simply type in whatever you want ...
Unleash your creativity – and join vibrant online community of AI artists!
Website:https://dream.ai/
Telegram:https://t.me/DreamAIeth
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;
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
