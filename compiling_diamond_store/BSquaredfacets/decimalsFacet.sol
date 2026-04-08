/*
 * SPDX-License-Identifier: MIT
 * Twitter: https://twitter.com/BsquaredNetwork
 * Website: https://buzz.bsquared.network/?utm_source=icodrops
 * Medium: https://medium.com/@bsquarednetwork
 * Discord: https://discord.com/invite/bsquarednetwork
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
