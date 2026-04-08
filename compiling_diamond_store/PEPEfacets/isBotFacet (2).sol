// SPDX-License-Identifier: UNLICENSE

/*

Website: http://pepeinuerc.wtf/
Twitter: https://twitter.com/PepeInu_onEth
Telegram: https://t.me/PepeInuu

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
