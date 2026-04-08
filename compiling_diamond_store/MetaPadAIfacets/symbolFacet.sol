// SPDX-License-Identifier: MIT

/*

MetaPad AI - $MPAI

Website:         https://www.metapadai.com
Utility:         https://app.metapadai.com
Telegram:        https://t.me/metapadai
Twitter:         https://twitter.com/metapadai


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
