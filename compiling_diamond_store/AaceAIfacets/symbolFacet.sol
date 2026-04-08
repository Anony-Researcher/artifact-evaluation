// SPDX-License-Identifier: MIT

/*
    Website  : https://www.aaceai.tech
    DApp     : https://app.aaceai.tech

    Telegram : https://t.me/aaceai
    Twitter  : https://twitter.com/AaceAI
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
