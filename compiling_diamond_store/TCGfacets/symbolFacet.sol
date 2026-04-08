// SPDX-License-Identifier: MIT

/***

Website:    https://www.tensorcoregpu.com
DApp:       https://app.tensorcoregpu.com
Document:   https://docs.tensorcoregpu.com

Twitter:    https://twitter.com/tensorcoregpu
Telegram:   https://t.me/tensorcoregpu

***/

pragma solidity 0.8.21;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
