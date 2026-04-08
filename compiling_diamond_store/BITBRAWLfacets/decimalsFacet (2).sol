/*
 * SPDX-License-Identifier: MIT
 * Website: https://bitbrawl.io
 * X: https://twitter.com/bitbrawlio
 * Telegram: https://t.me/BitbrawlGlobal
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
