/*
 * SPDX-License-Identifier: MIT
 * Website: https://mystiko.network
 * X: https://twitter.com/MystikoNetwork
 * Telegram: https://t.me/Mystiko_Network
 * Medium: https://medium.com/@Mystiko.Network
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
