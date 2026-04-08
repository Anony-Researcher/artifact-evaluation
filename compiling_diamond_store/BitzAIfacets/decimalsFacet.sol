// SPDX-License-Identifier: MIT

/*
    Dapp:       https://www.bitzai.app

    Twitter:    https://twitter.com/bitz_ai    
    Medium:     https://medium.com/@bitzai

    Telegram:   https://t.me/bitz_ai_app
*/
pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
