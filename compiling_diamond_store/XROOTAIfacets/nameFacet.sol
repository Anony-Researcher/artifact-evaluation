// SPDX-License-Identifier: MIT
/*
XRootAI Website: https://www.xrootai.com/
XRootAI Telegram Bot: https://t.me/XRootAIBot
XRootAI Whitepaper: https://whitepaper.xrootai.com

Twitter: https://twitter.com/XRootAI
Telegram: https://t.me/XRootAI
Mail: contact@xrootai.com

Medium: https://medium.com/@XRootAI
Zealy: https://zealy.io/c/xrootai

*/

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
