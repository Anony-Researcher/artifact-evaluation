// SPDX-License-Identifier: MIT

/*
    Web      : https://charmai.tech
    App      : https://app.charmai.tech
    Twitter  : https://twitter.com/charmai_tech
    Docs     : https://docs.charmai.tech
    Telegram : https://t.me/charmai_tech_channel
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
