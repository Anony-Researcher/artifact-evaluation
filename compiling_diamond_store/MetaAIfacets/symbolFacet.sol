// SPDX-License-Identifier: MIT

/*
    Website:    https://www.metaaichain.net
    Chat App:   https://chat.metaaichain.net
    Chain:      https://network.metaaichain.net
    Docs:       https://docs.metaaichain.net

    Telegram:   https://t.me/meta_ai_chain
    Twitter:    https://twitter.com/MetaAIChain
*/
pragma solidity 0.8.19;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
