// SPDX-License-Identifier: MIT

/*
    Web      : https://axiswap.com
    App      : https://app.axiswap.com
    Doc      : https://gitbook.axiswap.com

    Twitter  : https://twitter.com/axiswaplabs
    Telegram : https://t.me/axiswap_official
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract isNoAxiswapFeeWalletXFacet {
    using SafeMath for uint256;

    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isNoAxiswapFeeWalletX(
        address account
    ) external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._noAxiswapFee[account];
    }
}
