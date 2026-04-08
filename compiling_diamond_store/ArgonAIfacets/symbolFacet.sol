// SPDX-License-Identifier: MIT

/*
    Web      : https://argonai.us
    DApp     : https://app.argonai.us
    Docs     : https://docs.argonai.us

    Linktree : https://linktr.ee/argonaiprotocol
    Twitter  : https://twitter.com/argonaiprotocol
    Telegram : https://t.me/argonai_official
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
