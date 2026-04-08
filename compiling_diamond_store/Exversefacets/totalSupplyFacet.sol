/*
 * SPDX-License-Identifier: MIT
 * Website: https://exv.io/
 * Telegram: https://t.me/exverse
 * Twitter: https://twitter.com/exverse_io
 */
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
