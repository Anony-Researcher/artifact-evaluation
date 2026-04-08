/**
//SPDX-License-Identifier: MIT

/**
Telegram: https://t.me/ducketh_portal
Website: www.duck.fun
X: https://x.com/ducketh_
Discord: https://discord.gg/YTZtZSFtmy
*/
pragma solidity ^0.8.18;
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
