/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.gate.io/
 * Telegram: https://t.me/gateio_en
 * Twitter: https://twitter.com/gate_io
 * facebook: https://www.facebook.com/gateioglobal
 * Discord: https://airdrops.io/visit/kpn2/
 * Reddit: https://airdrops.io/visit/lpn2/
 */
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
