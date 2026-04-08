// SPDX-License-Identifier: MIT

/*
    Web      : https://batteryai.loans
    DApp     : https://app.batteryai.loans
    Docs     : https://docs.batteryai.loans

    Twitter  : https://twitter.com/BatteryAIX
    Telegram : https://t.me/batteryai_official

*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract isNoBatteryFeeWalletXFacet {
    using SafeMath for uint256;

    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isNoBatteryFeeWalletX(
        address account
    ) external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._noBatteryFee[account];
    }
}
