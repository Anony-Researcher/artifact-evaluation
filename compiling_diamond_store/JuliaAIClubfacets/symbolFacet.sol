// SPDX-License-Identifier: MIT

/*
    Web:        https://juliaai.club
    Dex:        https://dex.juliaai.club

    Twitter:    https://twitter.com/juliaaiclub
    Telegram:   https://t.me/juliaai_club
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
