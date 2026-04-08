// SPDX-License-Identifier: MIT

/*
    Web   : https://utopai.club
    App   : https://app.utopai.club
    Doc   : https://docs.utopai.club

    Twitter  : https://twitter.com/utopaiclub
    Telegram : https://t.me/utopai_official
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
