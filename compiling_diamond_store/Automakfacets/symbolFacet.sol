// SPDX-License-Identifier: MIT

/*
    Web:       https://automak.xyz
    App:       https://app.automak.xyz
    Doc:       https://docs.automak.xyz

    Twitter:   https://twitter.com/automakfi
    Telegram:  https://t.me/automak_official
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
