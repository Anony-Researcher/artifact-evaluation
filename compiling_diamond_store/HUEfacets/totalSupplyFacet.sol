// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.heurist.ai/
    Twitter:  https://twitter.com/heurist_ai
    Discord:  https://discord.com/heuristai
    Medium:   https://heuristai.medium.com/

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
}
