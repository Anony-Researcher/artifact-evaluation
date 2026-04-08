/*
 * SPDX-License-Identifier: MIT
 * Website: https://agoradex.io/
 * X: https://twitter.com/AgoraDex
 * Telegram: https://t.me/agoradex
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
