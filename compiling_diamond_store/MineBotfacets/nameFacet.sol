/**


⛏ WEBSITE - https://www.minebotofficial.com/

⛏ TWITTER - https://twitter.com/minebotofficial

⛏ GITBOOK - https://minebot.gitbook.io/minebot/

⛏ MEDIUM - https://medium.com/@minebotethereum

⛏ LINKTRE - https://linktr.ee/mineboterc20

⛏ TELEGRAM BOT - https://t.me/mineerc20bot


*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.9;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
