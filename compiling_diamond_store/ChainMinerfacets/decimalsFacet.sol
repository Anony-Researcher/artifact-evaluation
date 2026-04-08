/**
Website: Chainminer.io
Telegram: https://t.me/Chainminerio
Twitter: https://twitter.com/ChainMinerio
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
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
