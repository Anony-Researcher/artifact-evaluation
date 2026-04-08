/**
 */

// SPDX-License-Identifier: UNLICENSE
//website:http://www.elonbotai.buzz/
//Twitter:https://twitter.com/ElonbotA_MEME
//telegram:https://t.me/ElonBotAI_MEMEToken1

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
