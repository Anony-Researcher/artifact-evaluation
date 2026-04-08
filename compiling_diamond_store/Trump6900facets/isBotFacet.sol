// SPDX-License-Identifier: MIT

/*
Website: https://trump6900coin.com

Twitter: twitter.com/TAGAMemecoin

Telegram: https://t.me/TAGAPortal

Linktree: https://linktr.ee/TAGA6900

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
