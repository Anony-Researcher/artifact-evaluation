// SPDX-License-Identifier: MIT

/**

    Website:    https://reveallabs.org
    Platform:   https://revealbot.org
    Twitter:    https://twitter.com/RevealLabs_
    Telegram:   https://t.me/Reveal_Labs

*/

pragma solidity 0.8.20;
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
