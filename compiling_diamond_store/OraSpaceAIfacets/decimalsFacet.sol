// SPDX-License-Identifier: MIT

/*
    Web    : https://oraspaceai.com
    DApp   : https://app.oraspaceai.com
    Docs   : https://docs.oraspaceai.com

    Twitter  : https://twitter.com/OraSpaceAI
    Telegram : https://t.me/oraspaceai
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
