// SPDX-License-Identifier: MIT

/*
    Web      : https://ultron.lol
    App      : https://stake.ultron.lol

    Medium   : https://ultraonai.medium.com
    Twitter  : https://twitter.com/ultronprotocol
    Telegram : https://t.me/ultronai_official
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
