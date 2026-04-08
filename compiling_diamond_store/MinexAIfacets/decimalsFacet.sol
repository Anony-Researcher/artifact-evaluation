// SPDX-License-Identifier: MIT

/*

MinexAI Builder is an innovative project harnessing the power of cutting-edge AI technology to revolutionize software development.

Telegram - https://t.me/Minex_AI

Website - https://MinexAI.com/

Twitter (X) - https://twitter.com/MinexAI_dex

Docs - https://minexai.gitbook.io/docs

*/

pragma solidity 0.8.19;
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
