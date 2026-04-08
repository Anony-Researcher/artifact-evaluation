/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.thesoftdao.com
 * X: https://twitter.com/thesoftdao
 * Tele: https://t.me/theSoftDAO
 * Discord: https://discord.com/invite/thesoftdao
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
