/*
 * SPDX-License-Identifier: MIT
 * Website: https://truflation.com/
 * Telegram: https://t.me/truflation
 * Twitter: https://twitter.com/truflation
 */
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
