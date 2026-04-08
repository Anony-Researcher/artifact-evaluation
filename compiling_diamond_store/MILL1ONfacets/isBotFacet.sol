/*
$MILL1ON
Sniff. Bark. Moonshot.
One in a Million Inu is not your regular backyard dig.
WEB     https://mill1on.vip
TG      https://t.me/OneinaMillionInu
X       https://twitter.com/MILL1ON_Inu
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
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
