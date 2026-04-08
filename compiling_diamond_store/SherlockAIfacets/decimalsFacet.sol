/* 
Welcome to Sherlock, the cutting-edge cryptocurrency project designed to revolutionize the way you interact with your digital assets. At the heart of Sherlock lies its flagship feature: the Sherlock bot. This intelligent bot serves as your top-end wallet analyzer, offering unparalleled insights into your cryptocurrency holdings.

Telegram : https://t.me/SherlockAiERC

Website : https://sherlockerc20.com

Telegram Bot : t.me/SherlockTokenBot

**/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;
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
