// SPDX-License-Identifier: MIT

/*

DappGuard - Enhancing Security and Trust in Decentralized Applications

Telegram - https://t.me/DappGuard

Website - https://DappGuard.pro/

Twitter (X) - https://twitter.com/Dapp_Guard

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
