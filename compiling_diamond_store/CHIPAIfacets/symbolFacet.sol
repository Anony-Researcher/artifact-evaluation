/*
Website: https://chipai.app
Documentation: https://docs.chipai.app
X: https://twitter.com/chipai_eth
Telegram : https://t.me/chipai_eth
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.18;
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
