/*
 * SPDX-License-Identifier: MIT
 * Website: https://darkmachinegame.com/
 * X: https://twitter.com/DarkMachineGame
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
