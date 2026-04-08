/**
// SPDX-License-Identifier: UNLICENSE

------------BlackSock Capital------------


https://t.me/blacksockcapital
https://blacksockcapital.xyz/
https://twitter.com/BlackSockETH
https://x.com/elonmusk/status/1544374564255309826?s=20

Because Socks simply outperform Rocks


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
