// SPDX-License-Identifier: MIT

/*
    Web  : https://axionai.tech
    App  : https://app.axionai.tech
    Doc  : https://docs.axionai.tech

    Twitter  : https://twitter.com/axionaifin
    Telegram : https://t.me/axionai_portal
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
