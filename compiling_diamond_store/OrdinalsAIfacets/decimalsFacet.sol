// SPDX-License-Identifier: MIT

/*
    Website:    https://www.ordinalsai.systems
    DApp:       https://app.ordinalsai.systems

    Telegram:   https://t.me/OrdinalsAI_Portal
    Twitter:    https://twitter.com/OrdinalsAI_SYS
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
