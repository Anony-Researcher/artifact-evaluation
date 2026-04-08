/**
Complexion is a revolutionary crypto project that aims to transform the way individuals access and utilize GPU computing power for various computational tasks. Leveraging the power of blockchain technology and Telegram's user-friendly interface, Complexion introduces a seamless and efficient platform for renting GPU resources directly through a Telegram bot.

    Website: https://complexion.tech/
    Telegram: https://t.me/ComplexionERC
    Twitter:  https://twitter.com/ComplexionERC
    Bot: https://t.me/ComplexionBot


**/

// SPDX-License-Identifier: MIT

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
