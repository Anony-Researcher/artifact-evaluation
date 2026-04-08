// SPDX-License-Identifier: MIT

/*
    Introducing amazing AI platform Alphie ...

    Website  : https://www.alphieai.xyz
    App      : https://app.alphieai.xyz

    Telegram : https://t.me/AlphieAI_portal
    Twitter  : https://twitter.com/AlphieAI
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
