// SPDX-License-Identifier: MIT

/***

Web:    https://www.finexaai.com
App:    https://app.finexaai.com
Doc:    https://docs.finexaai.com

Tg:     https://t.me/finexaai
X:      https://x.com/finexaai

***/

pragma solidity 0.8.22;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
