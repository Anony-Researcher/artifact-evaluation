/*
 * SPDX-License-Identifier: MIT
 * Website: https://airdrops.io/visit/97n2/
 * Twitter: https://twitter.com/paramlaboratory
 * Discord Chat: https://airdrops.io/visit/a7n2/
 */
pragma solidity ^0.8.21;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
