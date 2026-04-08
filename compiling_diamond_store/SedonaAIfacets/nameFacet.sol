// SPDX-License-Identifier: MIT

/*
    Web      : https://sedona.cash
    App      : https://app.sedona.cash
    Docs     : https://docs.sedona.cash

    Twitter  : https://twitter.com/AIsedonaX
    Telegram : https://t.me/aisedona_official
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
