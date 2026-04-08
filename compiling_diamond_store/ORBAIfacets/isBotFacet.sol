/********
█▀█ █▀█ █▄▄   ▄▀█ █   █▀▀ █▀▀ █▄░█ █▀▀ █▀█ ▄▀█ ▀█▀ █▀█ █▀█
█▄█ █▀▄ █▄█   █▀█ █   █▄█ ██▄ █░▀█ ██▄ █▀▄ █▀█ ░█░ █▄█ █▀▄

ORBAI is the ultimate AI-generated content layer and AI asset factory and distribution platform for web3, games, and the metaverse.

Factory:   https://www.orbaigen.com
Document:  https://docs.orbaigen.com
X:         https://x.com/orbaigen
Telegram:  https://t.me/orbaigen
********/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
