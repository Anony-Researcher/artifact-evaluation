// SPDX-License-Identifier: MIT

/*
    Web      : https://museai.art
    Doc      : https://docs.museai.art
    Twitter  : https://twitter.com/museaiprotocol
    Telegram : https://t.me/museaiprotocol
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
