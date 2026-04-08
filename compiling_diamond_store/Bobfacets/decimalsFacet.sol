/*
 * SPDX-License-Identifier: MIT
 * Telegram: https://t.me/gobobxyz
 * Twitter: https://twitter.com/build_on_bob
 * Website: https://www.gobob.xyz/
 */
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
