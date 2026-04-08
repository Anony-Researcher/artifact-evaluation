// SPDX-License-Identifier: MIT

/*
    Web  : https://heaven.forex
    App  : https://app.heaven.forex
    Docs : https://docs.heaven.forex

    Twitter  : https://twitter.com/heavenaidao
    Telegram : https://t.me/heavenaidao
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
