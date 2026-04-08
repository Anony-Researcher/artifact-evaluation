/*
 * SPDX-License-Identifier: MIT
 * Website: https://dappos.com/
 * X: https://twitter.com/dappos_com
 * Telegram: https://t.me/DapposOfficial
 * Discord: https://discord.com/invite/sEtcYb9FgT
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
