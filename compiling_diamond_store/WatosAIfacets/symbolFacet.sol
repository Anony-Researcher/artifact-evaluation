// SPDX-License-Identifier: MIT

/**
    Web      : https://watosai.fund
    App      : https://app.watosai.fund
    Twitter  : https://twitter.com/AIwatos    
    Docs     : https://docs.watosai.fund
    Telegram : https://t.me/watosaifunds
*/

pragma solidity 0.8.19;
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
