// SPDX-License-Identifier: UNLICENSED

/*
Socials

Telegram: https://t.me/PaperClippyToken_entry

Tweet: https://x.com/elonmusk/status/1768750619525824628?s=46
*/
pragma solidity 0.8.17;
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
