// SPDX-License-Identifier: MIT

/**
    Web     : https://timeai.app
    App     : https://pay.timeai.app
    Docs    : https://docs.timeai.app

    Twitter : https://twitter.com/xtimeai
    Telegram: https://t.me/timeaigroup
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
