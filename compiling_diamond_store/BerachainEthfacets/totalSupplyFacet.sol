/*
 * SPDX-License-Identifier: MIT
 * Website: https://berachain.com
 * X: https://twitter.com/berachain
 * Discord: https://discord.gg/berachain
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
