// SPDX-License-Identifier: UNLICENSE

/* 

Ｔｒｕｍｐ＇ｓ Ｉｎｕ ｜ ＄ＢＩＤＥＮ

Telegram: https://t.me/TrumpsInu
X: https://twitter.com/TrumpInuERC20
Website: https://www.trumpsinu.com
*/

pragma solidity 0.8.23;
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
