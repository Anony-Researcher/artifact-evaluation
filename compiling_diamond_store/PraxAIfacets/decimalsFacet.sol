// SPDX-License-Identifier: MIT

/*
    Web    :  https://praxai.xyz
    DApp   :  https://app.praxai.xyz
    Docs   :  https://docs.praxai.xyz

    Twitter  : https://twitter.com/prxdao
    Telegram : https://t.me/praxai_platform
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
