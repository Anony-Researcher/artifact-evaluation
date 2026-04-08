// SPDX-License-Identifier: MIT

/***

Website:   https://www.verismcloud.com
DApp:      https://app.verismcloud.com

Twitter:   https://twitter.com/verismcloud_erc
Telegram:  https://t.me/verismcloud_official_channel

***/

pragma solidity 0.8.20;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
