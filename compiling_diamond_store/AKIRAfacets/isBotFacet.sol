//SPDX-License-Identifier: MIT

/**


https://x.com/discussingfilm/status/1765939814493515879?s=46&t=AAeulnrJ8097JIfGWHF2cQ
https://t.me/Akira_ERC

**/

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
