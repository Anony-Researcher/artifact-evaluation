// SPDX-License-Identifier: MIT

/*
    Web  : https://fractalai.net
    Doc  : https://docs.fractalai.net

    Twitter  : https://twitter.com/fractalaifin
    Telegram : https://t.me/fractalaifin_chat
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
