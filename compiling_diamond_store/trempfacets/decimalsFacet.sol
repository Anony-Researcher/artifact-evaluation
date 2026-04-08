// SPDX-License-Identifier: MIT
/**

mek memes gret agen

web: https://tremp.meme

tg: https://t.me/dolandtrempcoyn

x: https://twitter.com/dolantrempcoyn

**/
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
